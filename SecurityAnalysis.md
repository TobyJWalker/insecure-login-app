## Security Analysis

Here is a report of my findings when analysing this application for security vulnerabilities. I will use a mix of tools and manual testing to scan for and test vulnerabilities. For each find, I will list how I found it, what it is, and steps takento fix it.


### 1. SQL Injection

Method: ZAP + Manual testing

ZAP found that the login form was vulnerable to SQl injection. I was able to exploit the username field with the following input:
```
username' OR 1=1 --
```
Throughout Zap's testing, it also flooded the database entirely with its test data, which can be very problematic for a production database.

To fix this vulnerability, I replaced the standard string formatting with prepared statements so that the inputs are properly escaped. ZAP no longer finds any SQL injection vulnerabilities.

### 2. Plaintext Passwords

Method: Manual Scanning

During analysis of the database file, I found that account passwords are stored in plaintext. This is a major issue, as if the database is ever compromised, all login details will be exposed to the public.

To fix this, I have implemented a basic sha256 hashing to passwords on registration and login. There are additional steps such as salting which can also be applied but sha256 is a good start.

### 3. No HTTPS

Method: Manual Scanning

The application does not use HTTPS, meaning that any malicious threat actors can intercept traffic using a packet sniffer and steal login details. This is a major issue as it can lead to account hijacking.

To fix this, a certificate will need to be generated and signed, and included for ssl context so that the application can be served over HTTPS. I have not gone through this process but it is worth noting.

### 4. Secret Key in Source Code

Method: Manual Scanning

The secret key for flask which handles sessions is stored in plaintext in the source code. This is a major issue as it can be used to carry out session forgery and hijack accounts.

To overcome this, I have moved the secret key to be configured to be pulled from environment variables. This can then be stored elsewhere on a system which isn't in the source code. I have not configured the dockerfile to include this environment variable, as that would put in back into potential threat range so a docker secret will have to be configured.
