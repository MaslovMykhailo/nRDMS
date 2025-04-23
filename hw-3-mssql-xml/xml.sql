CREATE DATABASE currency;
USE currency;

DECLARE @XML_SRC XML;
SET @XML_SRC = (
    SELECT * FROM OPENROWSET(BULK '/var/opt/mssql/data/eurofxref-hist-90d.xml', SINGLE_BLOB) AS x
);

CREATE TABLE tblCurrency (
    CurrencyCode NVARCHAR(3) PRIMARY KEY,
    CurrencyName NVARCHAR(100) NULL
);

CREATE TABLE tblCurrencyRate (
    RateDate DATE,
    CurrencyCode NVARCHAR(3),
    Rate DECIMAL(18,6),
    PRIMARY KEY (RateDate, CurrencyCode),
    FOREIGN KEY (CurrencyCode) REFERENCES tblCurrency(CurrencyCode)
);

WITH XMLNAMESPACES (
    'http://www.gesmes.org/xml/2002-08-01' AS gesmes,
    DEFAULT 'http://www.ecb.int/vocabulary/2002-08-01/eurofxref'
)
INSERT INTO tblCurrency (CurrencyCode)
SELECT DISTINCT
    C.C.value('@currency', 'VARCHAR(3)') AS CurrencyCode
FROM @XML_SRC.nodes('/gesmes:Envelope/Cube/Cube') AS T(C)
CROSS APPLY T.C.nodes('Cube') AS C(C)
WHERE C.C.value('@currency', 'VARCHAR(3)') NOT IN (SELECT CurrencyCode FROM tblCurrency);

WITH XMLNAMESPACES (
    'http://www.gesmes.org/xml/2002-08-01' AS gesmes,
    DEFAULT 'http://www.ecb.int/vocabulary/2002-08-01/eurofxref'
)
INSERT INTO tblCurrencyRate (RateDate, CurrencyCode, Rate)
SELECT
    CONVERT(DATE, T.C.value('@time', 'VARCHAR(10)')) AS RateDate,
    C.C.value('@currency', 'VARCHAR(3)') AS CurrencyCode,
    C.C.value('@rate', 'DECIMAL(18,6)') AS Rate
FROM @XML_SRC.nodes('/gesmes:Envelope/Cube/Cube') AS T(C)
CROSS APPLY T.C.nodes('Cube') AS C(C);

SELECT * FROM tblCurrency;
SELECT * FROM tblCurrencyRate;