import ballerina/ftp;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

final ftp:Client ftpClient = check new ({
    protocol: "sftp",
    host: ftpHost,
    port: ftpPort,
    auth: {
        credentials: {
            username: ftpUsername,
            password: ftpPassword
        }
    }
});
final mysql:Client mysqlClient = check new (dbHost, dbUsername, dbPassword, dbName, dbPort);
