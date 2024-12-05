To get token in regular intervals:
------------
Test Plan:
REQUEST_HOST = ${_P(REQUEST_HOST, url)}
PATH_PREFIX = ${_P(PATH_PREFIX, path)}
REQUEST_PROTOCOL = ${_P(REQUEST_PROTOCOL,https)}
AUTH_CLIENT_ID =${_P(AUTH_CLIENT_ID, clientid)}
AUTH_CLIENT_SECRET =${_P(AUTH_SECRET, clientsecret)}
ENV = ${_P(ENV,prod)}
AUTH_HOST =${_P(AUTH_HOST, auth host)}
CSV_DATA_SET = ${_P(CSV_DATA_SET, )}
TOKEN_RENEW_MSEC =${_P(TOKEN_RENEW_MSEC,60000 )}

-----------------------
User defined variables:
name = User defined variables
Name = Test run name
Value = name of your test

#1 Add a thread group = GetTokenThreadGroup
#2 Loop count infinite check
#3 Same user on each iteration check
#4 num of threads =1
#5 ramp up period =1

-------------

Add Search Request thread group
Add Simple controller

Add HTTP Header Manager
Name = Set Authorization token using the global var property
NAME> 
Content Type = Application.json
Authorization = Bearer ${_P(access_token_prop,)}

-------

HTTP Request
Protocol = https
Server Name = ${REQUEST_HOST}
HTTP Request = POST
Path = path
Check follow redirects
Use keep alive  check
Body Data: 
${request}

-------
Add CSV data config set
Name = CSV data set config
Filename = path to file
Variable names = columnName1,columnname2,etc
ignore first line in variable - true
DElimeter = ,
Allow quoted data = True
Recycle on EOF = False
Stop thread on EOF = True
Sharing mode= All threads

----------


CSV DATA set Config

Add a getToken Thread Group

Add a simple controler in the thread group for Authentication
Name = Authentication

-------------
Add a http requedt in the controller
name = GetToken

Protocol http = $(REQUEST_PROTOCOL)
Server Name IP = $(AUTH_HOST)

HTTP Request = POST
Path = oauth/accesstoken

Check follow redirects 
check keep alve

client id = $(AUTH_CLIENT_ID)
client secret = $(AUTH_CLIENT_SECRET)
grant type = client_credentials

--------------
Add json extractor in getToken
name = Extract access_token to local var
Apply to main sample and sub querries check
Names of created variables = access_token_var
JSON Path expressions = $.access_token
Match numebr =1

----
add JSR223 PostProcessor

name = copy local val to gloval var (property)
Language = Groovy
Cache compiled script if available check

script :
def acvar = var.get('access_token_var')
props.put('access_token_prop', String.valueOf(acvar))

------------

Flow control action
name = Flow control action
Logial action on thread = Pause
Duration = $(TOKEN_RENEW_MSEC)

----
