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

### 5. No CSRF Protection

Method: ZAP

ZAP found that there was no use of Anti-CSRF tokens in the application, meaning threats could use Cross-Site Request Forgery to carry out actions on behalf of a user.

To fix this, I have implemented the flask-wtf csrf protection module. This adds a csrf token to all forms, and checks that the token is valid when a form is submitted. This prevents CSRF attacks.

### 6. No X-Frame-Options Header

Method: ZAP

ZAP found that responses from the server did not include this header, which can be cause for mild concern. This header tells the browser to not render the page in a frame or iframe, which can prevent clickjacking attacks.

I have fixed this by adding the 'SAMEORIGIN' header to all Flask responses.

### 7. No Content-Security-Policy Header for form-action and frame-ancestors

Method: ZAP

ZAP found that responses from the server did not include this header, which can be cause for mild concern. This header tells the browser which sources are allowed to be used for form actions and frame ancestors. This can prevent XSS and injection attacks.

I have fixed this by adding `form-action 'self'; frame-ancestors 'self';` to the Content-Security-Policy header for all Flask responses.

### 8. No X-Content-Type-Options Header

Method: ZAP

Zap found that responses from the server did not include this header, which can be cause for mild concern. This header tells the browser to not try and guess the content type of a response, and instead use the one provided by the server. This can prevent some attacks such as MIME sniffing.

I have fixed this by adding the 'nosniff' header to all Flask responses.

### 9. Server Header

Method: ZAP

Zap found that the python/werkzeug version could be found in the server header. This can be used by attackers to find vulnerabilities in the server software.

I cannot remove this header as the server is currently running on the flask development server. This will be fixed when the application is deployed to a production server.

### 10. No SameSite attribute on session cookie

Method: ZAP

Zap found that the session cookie did not have the SameSite attribute set. This can be used by attackers to carry out CSRF attacks.

I have fixed this by setting the SameSite attribute to 'Strict' on the session cookie. This could also be changed to Lax.