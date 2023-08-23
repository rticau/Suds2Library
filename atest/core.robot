*** Settings ***
Resource          resources/resource.robot

*** Variables ***
${JOHN PARSONS}    <?xml version="1.0" encoding="utf-8"?><SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:ns="urn:TestService"><SOAP-ENV:Body SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><ns:returnComplexTypeResponse><result><first-name>John</first-name><last-name>Parsons</last-name></result></ns:returnComplexTypeResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>

*** Test Cases ***
Using A Local WSDL
    [Documentation]    Local copy of WSDL likely has incorrect locations.
    Create Soap Client    ${CURDIR}${/}resources/wsdls/Calculator.wsdl
    ${sum}    Call Soap Method    add    1    41
    Should Be Equal As Numbers    ${sum}    42

Complex Argument Using A Dictionary
    [Documentation]    This is not the preferred way to use Suds.
    Create Soap Client    ${TEST WSDL URL}
    ${dict}    Evaluate    {'first-name':'George','last-name':'Cooper'}
    ${reply}    Call Soap Method    complexTypeArgument    ${dict}
    Should Be Equal As Strings    ${reply}    George Cooper

Set Return XML
    Create Soap Client    ${TEST WSDL URL}
    ${initial value}    Set Return Xml    True
    Should Not Be True    ${initial value}
    ${resp}    Call Soap Method    returnComplexType    John    Parsons
    Should Be Equal As Strings    ${resp}    ${JOHN PARSONS}
    ${new value}    Set Return Xml    false
    Should Be True    ${new value}
    ${resp}    Call Soap Method    returnComplexType    John    Parsons
    Should Not Be Equal As Strings    ${resp}    ${JOHN PARSONS}

Unexpected Fault
    Create Soap Client    ${TEST WSDL URL}
    Run Keyword And Expect Error    WebFault: b"Server raised fault: 'fault message'"    Call Soap Method    fault    fault message

Expecting Fault
    Create Soap Client    ${TEST WSDL URL}
    ${fault}    Call Soap Method Expecting Fault    fault    the sky is falling
    Should Be Equal As Strings    ${fault.faultstring}    the sky is falling

Expecting Fault But No Fault Occurs
    Create Soap Client    ${TEST WSDL URL}
    Run Keyword And Expect Error    The server did not raise a fault.    Call Soap Method Expecting Fault    theAnswer

Expecting Fault w/ retxml
    Create Soap Client    ${TEST WSDL URL}
    Set Return Xml    true
    ${resp}    Call Soap Method Expecting Fault    fault    oh no
    Should Start With    ${resp}    <?xml
    Element Text Should Be    ${resp}    oh no    Body/Fault/faultstring

Complex Type Argument
    Create Soap Client    ${TEST WSDL URL}
    ${person}    Create Wsdl Object    Person
    Set Wsdl Object Attribute    ${person}    first-name    Phillip
    Set Wsdl Object Attribute    ${person}    last-name    McCann
    ${resp}    Call Soap Method    complexTypeArgument    ${person}
    Should Be Equal As Strings    ${resp}    Phillip McCann

Set Port
    Create Soap Client    ${CURDIR}${/}resources/wsdls/TestService_ports.wsdl
    Run Keyword And Expect Error    *    Call Soap Method    theAnswer
    Set Port    TestService
    Call Soap Method    theAnswer
    Set Port    0
    Run Keyword And Expect Error    *    Call Soap Method    theAnswer
    Set Port    1
    Call Soap Method    theAnswer

Set Service
    Create Soap Client    ${TEST WSDL URL}
    Create Soap Client    ${CURDIR}${/}resources/wsdls/TestService_services.wsdl
    Run Keyword And Expect Error    *    Call Soap Method    theAnswer
    Set Service    TestService
    Call Soap Method    theAnswer
    Set Service    0
    Run Keyword And Expect Error    *    Call Soap Method    theAnswer
    Set Service    1
    Call Soap Method    theAnswer

Specific Call - Port
    Create Soap Client    ${CURDIR}${/}resources/wsdls/TestService_ports.wsdl
    Run Keyword And Expect Error    *    Call Soap Method    theAnswer
    Specific Soap Call    ${None}    1    theAnswer
    Specific Soap Call    \    TestService    theAnswer
    Run Keyword And Expect Error    *    Call Soap Method    theAnswer
    Set Port    BadPort
    Specific Soap Call    ${EMPTY}    TestService    theAnswer

Specific Call - Service
    Create Soap Client    ${CURDIR}${/}resources/wsdls/TestService_services.wsdl
    Run Keyword And Expect Error    *    Call Soap Method    theAnswer
    Set Service    HEY OH
    Specific Soap Call    1    ${None}    theAnswer
    Specific Soap Call    TestService    \    theAnswer

Set Proxy
    Create Soap Client    ${TEST WSDL URL}
    Call Soap Method    theAnswer
    Set Proxies    http    localhost:9090
    Run Keyword And Expect Error    *No connection could be made because the target machine actively refused it*    Call Soap Method    theAnswer

Return XML And Verify With XML Library
    Create Soap Client    ${TEST WSDL URL}
    Set Return Xml    True
    ${resp}    Call Soap Method    returnComplexType    John    Parsons
    ${first name elem}    XML.Get Element    ${resp}    .//result/first-name
    Element Text Should Be    ${first name elem}    John

Two Clients By Index
    ${calc index}    Create Soap Client    ${CALCULATOR WSDL URL}
    ${test index}    Create Soap Client    ${TEST WSDL URL}
    Switch Soap Client    ${calc index}
    ${sum}    Call Soap Method    add    1    1
    Should Be Equal As Numbers    ${sum}    2
    Switch Soap Client    ${test index}
    ${answer}    Call Soap Method    theAnswer
    Should Be Equal As Numbers    ${answer}    42

Two Clients By Alias
    Create Soap Client    ${CALCULATOR WSDL URL}    calc
    Create Soap Client    ${TEST WSDL URL}    test
    Switch Soap Client    c A l C
    ${sum}    Call Soap Method    add    1    1
    Should Be Equal As Numbers    ${sum}    2
    Switch Soap Client    test
    ${answer}    Call Soap Method    theAnswer
    Should Be Equal As Numbers    ${answer}    42

Two Clients Different Settings
    Create Soap Client    ${TEST WSDL URL}    test
    Set Return Xml    True
    Create Soap Client    ${CALCULATOR WSDL URL}    calc
    ${sum}    Call Soap Method    add    1    1
    Should Be Equal As Numbers    ${sum}    2
    Switch Soap Client    test
    ${resp}    Call Soap Method    returnComplexType    John    Parsons
    Should Be Equal As Strings    ${resp}    ${JOHN PARSONS}

ImportDoctor
    Create Soap Client    ${CURDIR}${/}resources/wsdls/TestService_missing_import.wsdl
    Run Keyword And Expect Error    TypeNotFound: Type not found: 'ns0:string'    Create Wsdl Object    ns0:string
    Add Doctor Import    http://schemas.xmlsoap.org/soap/encoding/
    Run Keyword And Expect Error    TypeNotFound: Type not found: 'ns0:string'    Create Wsdl Object    ns0:string
    Create Soap Client    ${CURDIR}${/}resources/wsdls/TestService_missing_import.wsdl
    Create Wsdl Object    ns0:string

SOAP Headers Using WSDL Object
    Create Soap Client    ${CURDIR}${/}resources/wsdls/soapheaders.wsdl
    ${auth header}    Create Wsdl Object    AuthHeader
    Set Wsdl Object Attribute    ${auth header}    UserName    gcarlson
    Set Wsdl Object Attribute    ${auth header}    Password    heyOh
    Set Soap Headers    ${auth header}
    Run Keyword And Ignore Error    Call Soap Method    DoIt
    ${last sent}    Get Last Sent
    ${last sent}    Convert To String    ${last sent}
    Should Contain    ${last sent}    <SOAP-ENV:Header><tns:AuthHeader><tns:UserName>gcarlson</tns:UserName><tns:Password>heyOh</tns:Password></tns:AuthHeader></SOAP-ENV:Header>

SOAP Headers Using Dict
    Create Soap Client    ${CURDIR}${/}resources/wsdls/soapheaders.wsdl
    ${auth dict}    Create Dictionary    UserName    sjenson    Password    power
    Set Soap Headers    ${auth dict}
    Run Keyword And Ignore Error    Call Soap Method    DoIt
    ${last sent}    Get Last Sent
    ${last sent}    Convert To String    ${last sent}
    Should Contain    ${last sent}    <SOAP-ENV:Header><tns:AuthHeader><tns:UserName>sjenson</tns:UserName><tns:Password>power</tns:Password></tns:AuthHeader></SOAP-ENV:Header>

Headers
    Create Soap Client    ${TEST WSDL URL}
    Set Headers    abc    123
    Call Soap Method    theAnswer
    ${request}    Get Sent Request
    Should Be Equal As Strings    ${request.headers['abc']}    123
    ${headers}    Create Dictionary    foo    bar
    Set Headers    ${headers}
    Call Soap Method    theAnswer
    ${request}    Get Sent Request
    Should Be Equal As Strings    ${request.headers['foo']}    bar
    Run Keyword And Expect Error    ValueError: There should be an even number of name-value pairs.    Set Headers    1    2    3

Return ComplexType and Alter
    Create Soap Client    ${TEST WSDL URL}
    ${person}    Call Soap Method    returnComplexType    John    Parsons
    Set Wsdl Object Attribute    ${person}    first-name    Bob
    ${first name}    Get Wsdl Object Attribute    ${person}    first-name
    Should Be Equal As Strings    ${first name}    Bob

Set Location
    Create Soap Client    ${TEST WSDL URL}
    Set Location    http://localhost:8080/badpath
    Run Keyword And Expect Error    *    Call Soap Method    theAnswer
    Set Location    http://localhost:8080/TestService/soap11/
    Call Soap Method    theAnswer
    Set Location    http://localhost:8080/badpath    names=complexTypeArgument
    ${dict}    Evaluate    {'first-name':'George','last-name':'Cooper'}
    Run Keyword And Expect Error    *    Call Soap Method    complexTypeArgument    ${dict}
    Call Soap Method    theAnswer
    Create Soap Client    ${CURDIR}${/}resources/wsdls/TestService_services.wsdl
    Set Location    http://localhost:8080/TestService/soap11/    names=theAnswer
    Specific Soap Call    0    \    theAnswer
    Specific Soap Call    1    \    theAnswer
    Run Keyword And Expect Error    ServiceNotFound: Service not found: 'wohoo'    Set Location    http://localhost:8080/badpath    wohoo

Suds Null Variable
    ${null string}    Convert To String    ${SUDS_NULL}
    Should Start With    ${null string}    <suds.null

Set Soap Logging
    [Documentation]    LOG 2 INFO STARTS: Sending:
    ...    <?xml
    ...    LOG 6 NONE
    ...    LOG 8 INFO STARTS: Sending:
    ...    <?xml
    ...    LOG 10 NONE LOG 13 INFO STARTS: Sending:
    ...    <?xml
    Create Soap Client    ${TEST WSDL URL}    on
    Call Soap Method    theAnswer
    Create Soap Client    ${TEST WSDL URL}    off
    ${initial value}    Set Soap Logging    false
    Should Be True    ${initial value}
    Call Soap Method    theAnswer
    Switch Soap Client    on
    Call Soap Method    theAnswer
    Switch Soap Client    off
    Call Soap Method    theAnswer
    ${new value}    Set Soap Logging    true
    Should Not Be True    ${new value}
    Call Soap Method    theAnswer

Soap Logging Options
    [Documentation]    LOG 2 INFO REGEXP: .*(\\x0A|\\x0C)\\ {2}<SOAP-ENV:Header.*
    ...    LOG 4 INFO REGEXP: .*(\\x0A|\\x0C)\\ {4}<SOAP-ENV:Header.*
    ...    LOG 6 INFO REGEXP: .*><SOAP-ENV:Header.*
    Create Soap Client    ${TEST WSDL URL}
    Call Soap Method    theAnswer
    Set Soap Logging    true    indent=4
    Call Soap Method    theAnswer
    Set Soap Logging    true    prettyxml=false
    Call Soap Method    theAnswer

Get Last Sent/Received
    Create Soap Client    ${TEST WSDL URL}
    ${last sent}    Get Last Sent
    Should Be Equal    ${last sent}    ${None}
    ${last received}    Get Last Received
    Should Be Equal    ${last received}    ${None}
    Call Soap Method    theAnswer
    ${last sent}    Get Last Sent
    ${last sent}    Convert To String    ${last sent}
    Should Start With    ${last sent}    <?xml
    ${last received}    Get Last Received
    ${last received}    Convert To String    ${last received}
    Should Start With    ${last received}    <?xml
    ${lib}    Get Library Instance    Suds2Library
    ${client}    Call Method    ${lib}    _client
    Remove From List    ${client.options.plugins}    0
    Run Keyword And Expect Error    The Suds2Library SOAP logging message plugin has been removed.    Get Last Sent

Create/Get Wsdl Object
    Create Soap Client    ${TEST WSDL URL}
    ${person}    Create Wsdl Object    Person    first-name    Phillip    last-name    McCann
    ${first name}    Get Wsdl Object Attribute    ${person}    first-name
    ${last name}    Get Wsdl Object Attribute    ${person}    last-name
    Should Be Equal As Strings    ${first name}    Phillip
    Should Be Equal As Strings    ${last name}    McCann
    Run Keyword And Expect Error    ValueError: Creating a WSDL object failed. There should be an even number of name-value pairs.    Create Wsdl Object    Person    first-name
    Comment    suds and suds-jurko have slightly different error messages
    Run Keyword And Expect Error    AttributeError: *Person*has no attribute 'badname'    Create Wsdl Object    Person    badname    value
    Run Keyword And Expect Error    AttributeError: *Person*has no attribute 'badname'    Get Wsdl Object Attribute    ${person}    badname
    Run Keyword And Expect Error    ValueError: Object must be a WSDL object (suds.sudsobject.Object).    Get Wsdl Object Attribute    ${first name}    name

Set WSDL Object Attribute
    Create Soap Client    ${TEST WSDL URL}
    ${person}    Create Wsdl Object    Person
    Set Wsdl Object Attribute    ${person}    first-name    foo
    ${first name}    Get Wsdl Object Attribute    ${person}    first-name
    Should Be Equal As Strings    ${first name}    foo
    Comment    suds and suds-jurko have slightly different error messages
    Run Keyword And Expect Error    AttributeError: *Person*has no attribute 'badname'    Get Wsdl Object Attribute    ${person}    badname
    Run Keyword And Expect Error    ValueError: Object must be a WSDL object (suds.sudsobject.Object).    Set Wsdl Object Attribute    ${first name}    name    bob

Soap Timeout
    [Documentation]    LOG 4 INFO SOAP timeout set to 30 seconds
    Create Soap Client    ${TEST WSDL URL}    timeout=1 ms
    Set Soap Timeout    1 ms
    Run Keyword And Expect Error    timeout: timed out    Call Soap Method    theAnswer
    Set Soap Timeout    30s
    Call Soap Method    theAnswer

Default Socket Timeout Is Restored
    Create Soap Client    ${TEST WSDL URL}
    Set Global Socket Timeout    ${42}
    Call Soap Method    theAnswer
    Default Socket Timeout Should Be    ${42}
    Run Keyword And Ignore Error    Call Soap Method    theAnswer    badArg
    Default Socket Timeout Should Be    ${42}

Timeout Set On Create
    Create Soap Client    ${TEST WSDL URL}    timeout=45 sec
    ${sl}=    Get Library Instance    Suds2Library
    Should Be Equal As Numbers    ${sl._client().options.timeout}    45

Raw Soap Message
    [Documentation]    Includes testing message with unicode characters.
    Create Soap Client    ${TEST WSDL URL}
    ${message}=    Create Raw Soap Message    <?xml version="1.0" ?><SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns0="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="urn:TestService" xmlns:ns2="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns3="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><SOAP-ENV:Header/><ns2:Body><ns1:complexTypeArgument><person xsi:type="ns1:Person"><first-name xsi:type="ns3:string">Raúl</first-name><last-name xsi:type="ns3:string">Santiago</last-name></person></ns1:complexTypeArgument></ns2:Body></SOAP-ENV:Envelope>
    ${response}=    Call Soap Method    complexTypeArgument    ${message}
    Should Be Equal As Strings    ${response}    Raúl Santiago

Raw SOAP Message As String
    [Documentation]    Verify that raw SOAP messages can be used in string concatenation, logging, etc.
    ${message}=    Create Raw Soap Message    eggs
    Should Be Equal    spam and ${message}    spam and eggs

Unicode Attribute Value
    Create Soap Client    ${TEST WSDL URL}
    ${person}    Create Wsdl Object    Person    first-name    Raúl    last-name    Santiago
    ${resp}    Call Soap Method    complexTypeArgument    ${person}
    Should Be Equal As Strings    ${resp}    Raúl Santiago

Closing Client Expecting Error
    Create Soap Client    ${CALCULATOR WSDL URL}    calc
    ${sum}    Call Soap Method    add    1    1
    Should Be Equal As Numbers    ${sum}    2
    Close Connection
    Run Keyword And Expect Error  MethodNotFound:*    Call Soap Method    add    1    1

Two Clients Closing One
    Create Soap Client    ${CALCULATOR WSDL URL}    calc
    Create Soap Client    ${CALCULATOR WSDL URL}    calc
    ${sum}    Call Soap Method    add    1    1
    Should Be Equal As Numbers    ${sum}    2
    Close Connection
    ${sum}    Call Soap Method    add    2    2
    Should Be Equal As Numbers    ${sum}    4

Two Clients Close All And Expect Error
    Create Soap Client    ${CALCULATOR WSDL URL}    calc
    Create Soap Client    ${CALCULATOR WSDL URL}    calc
    ${sum}    Call Soap Method    add    1    1
    Should Be Equal As Numbers    ${sum}    2
    Close All Connections
    Run Keyword And Expect Error  No current client    Call Soap Method    add    2    2

*** Keywords ***
Default Socket Timeout Should Be
    [Arguments]    ${timeout}
    ${timeout after}=    Evaluate    socket.getdefaulttimeout()    socket
    Should Be Equal As Numbers    ${timeout after}    ${timeout}

Set Global Socket Timeout
    [Arguments]    ${timeout}
    ${socket}=    Evaluate    socket    socket
    Call Method    ${socket}    setdefaulttimeout    ${timeout}
