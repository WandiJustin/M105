--STEP 1 Als Erstes stellst du die Datenbank mit der angehängten Datei wieder her.
RESTORE DATABASE soundlib
FROM DISK = N'C:\Temp\soundlib.bak'
WITH
    MOVE 'soundlib' to 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\soundlib-backup.mdf',
    MOVE 'soundlib_log' to 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\soundlib-backup.ldf';

--2 Gib dein Geburtsdatum nach folgendem Muster mit der Spaltenüberschrift "About me" aus:  Ich, Hans Muster, habe am 01.01.2000 Geburtstag!
SELECT 'Ich, Justin Wandeler, habe am 14.02.2005 Geburtstag!' AS [About me]

--3 Liste alle Songs auf, bei denen der Komponist zugleich der Künstler ist. Die Liste soll nur den Songnamen enthalten.
USE soundlib
SELECT Track.Name FROM Track 
    JOIN Album ON Album.AlbumId = Track.AlbumId 
    JOIN Artist ON Artist.ArtistId = Album.ArtistId 
WHERE Artist.Name = Composer

--4 Erstelle eine Liste, die alle Rock-, Metall- und Heavy Metall-Bands anzeigt, welche nicht weniger als 4 Alben herausgebracht haben (Bandname, Anzahl Alben).
USE soundlib
SELECT Track.Composer, COUNT(Track.TrackID) FROM Track 
WHERE Track.GenreID = 1 OR Track.GenreID = 3 OR Track.GenreID = 1
GROUP BY Composer
HAVING COUNT(Track.TrackId) >= 4 
ORDER BY Composer

--5 Durch einen Gerichtsentscheid bekommen alle Kunden, welche zwischen dem 1.1.2009 und dem 30.6.2009 eine Rechnung erhalten haben, 30% des einbezahlten Betrags zurück. Damit diese Kunden per Brief angeschrieben werden können, benötigt das Sekretariat eine Liste mit folgenden Angaben: Firmennamen Name, Vorname, Adresse, Postleitzahl und City alphabetisch nach Namen sortiert. Kunden mit mehreren Aufträgen in dieser Zeit sollen, trotzdem nur einmal aufgelistet sein.
BEGIN TRANSACTION TRANSACTION1
DELETE FROM InvoiceLine
WHERE UnitPrice > 1 AND InvoiceId = 400
COMMIT TRANSACTION TRANSACTION1

--6 Firmennamen Name, Vorname, Adresse, Postleitzahl und City
SELECT DISTINCT Company, LastName, FirstName, Address, PostalCode, City FROM Customer
    JOIN Invoice ON Invoice.CustomerID = Customer.CustomerId
WHERE InvoiceDate > '1.1.2009 ' AND InvoiceDate < '30.6.2009'
ORDER BY LastName ASC
 
--7 Bei der Tabelle Employee muss gewährleistet sein, dass das Anstellungsdatum zeitlich immer nach dem Geburtsdatum liegt, auch wenn dieses Feld leer ist. Wie kannst du diese Bedingung umsetzen? Schreibe das SQL‐Statement auf.
SELECT ar.Name +'  -  '+ t.Name AS 'Interpret - Song', SUM(a.AlbumId) AS 'Vorkommen in Playlists' FROM Track t
JOIN Album a ON t.AlbumId=a.AlbumId
JOIN Artist ar ON a.ArtistId=ar.ArtistId
GROUP BY ar.Name, t.Name
ORDER BY [Vorkommen in Playlists] DESC

--8
SELECT FirstName, LastName FROM Employee
WHERE HireDate>BirthDate

--9 Prüfe unter Verwendung des geeigneten Joins, ob es in der DB Tracks gibt, welche noch nie gekauft wurden. In der Ausgabe sollen alle Spalten aufgeführt werden.
SELECT T.* FROM Track t
LEFT JOIN InvoiceLine il ON t.TrackId=il.TrackId
WHERE il.TrackId IS NULL

--10 Erstelle eine neue Playlist. Den Namen kannst du frei wählen. Füge deiner neuen Playlist anschliessend sämtliche Songs dreier Alben deiner Wahl hinzu. Das Einfügen der Songs soll dabei direkt über eine Abfrage erfolg
INSERT INTO Playlist (Name) VALUES ('MeinMix')
INSERT INTO PlaylistTrack (PlaylistTrack.PlaylistID, PlaylistTrack.TrackId) VALUES ('19','1')
INSERT INTO PlaylistTrack (PlaylistTrack.PlaylistID, PlaylistTrack.TrackId) VALUES ('19','2')
INSERT INTO PlaylistTrack (PlaylistTrack.PlaylistID, PlaylistTrack.TrackId) VALUES ('19','3')

--11 Ein Namensforscher kontaktiert dich und möchte gerne eine Auflistung mit allen unterschiedlichen Nachnamen Deiner Kunden haben. Erstelle für ihn die Liste, absteigend sortiert.
SELECT DISTINCT LastName FROM Customer
ORDER BY LastName DESC

--12 Erstelle einen weiteren Benutzer beziehungsweise ein weiteres Login (Name Deiner Wahl) mit folgenden Rechten.
USE master;
 CREATE LOGIN usertest WITH PASSWORD = 'passw0rd';

 USE soundlib;
 CREATE USER usertest FOR LOGIN usertest;

 GRANT SELECT  TO usertest;
 GRANT INSERT, UPDATE, DELETE ON InvoiceLine TO usertest;
 GRANT INSERT, UPDATE, DELETE ON Invoice TO usertest;
 GRANT INSERT, UPDATE, DELETE ON Customer TO usertest;
 GRANT INSERT, UPDATE, DELETE ON Employee TO usertest;

--13 Im Auftrag der Geschäftsleitung musst du eine Liste mit allen Kunden erstellen, deren KundenID multipliziert mit 4 grösser als die kleinste dreistellige Zahl ist. Die Liste soll die KundenID sowie den Nachnamen dieser Personen enthalten.
SELECT Customer.CustomerId, Customer.LastName FROM Customer
WHERE 111 < Customer.CustomerId * 4

--14 Du möchtest genauere Informationen über die Altersstruktur der Firma Soundlib gewinnen und listest dazu in aufsteigender Reihenfolge alle Jahrgänge der Mitarbeiter auf. Erstelle in einem ersten Schritt die Liste mit einer Spalte namens "Jahrgang". Als nächster Schritt interessiert dich der Durchschnittswert aller Jahrgänge. Finde ihn heraus mithilfe der geeigneten SQL‐Funktion.
--Step 1
SELECT YEAR(BirthDate) AS Jahrgang FROM Employee
ORDER BY YEAR(BirthDate) ASC
--Step 2
SELECT AVG(YEAR(BirthDate)) AS JahrgangsDurchschnitt FROM Employee

--15 John M. möchte wissen, wie viele Songs es in unserer Datenbank gibt.
SELECT COUNT(Track.TrackId) FROM Track

--16 Führe alle Songs mit Namen und Komponisten auf. Gib bei jedem Song an, ob es sich um eine sehr grosse (>= 1 GB), eine grosse (>= 100 MB und < 1 GB), eine mittlere (>= 10 und < 100 MB) oder um eine kleine Datei handelt.
SELECT Name, Composer, bytes, 
CASE
WHEN Bytes >= 1000000000 THEN 'sehr grosse Datei'
WHEN Bytes >= 100000000 AND Bytes < 1000000000 THEN 'grosse Datei'
WHEN Bytes >= 10000000 AND Bytes < 100000000 THEN 'mittlere Datei'
ELSE 'kleine datei'
END AS Groesse
FROM Track
WHERE Name IS NOT NULL AND Composer IS NOT NULL

--17 Damit dir nicht langweilig wird und du in Sachen SQL nicht aus der Übung kommst, listest du alle Tracks auf, welche mit denselben 3 Buchstaben beginnen wie Dein Vorname. Die Ausgabeliste soll nur eine Spalte mit dem Namen des Tracks enthalten.
SELECT Track.Name FROM Track
WHERE LEFT(Track.Name, 3) = 'jus'

--18 Um seine neuen Mitarbeiter besser kennenzulernen, lädt der Firmenbesitzer John M. von SoundLib jeweils am ersten Arbeitstag seine Mitarbeiter auf seine Yacht ein. Nun meinte John M., da an diesem Tag nicht gearbeitet wird, gilt dies auch nicht als Einstellungstag. Du hast nun die Aufgabe erhalten. Den Einstellungstag eines jeden Mitarbeiters um einen Tag nach hinten zu verschieben. Verwende dafür eine vordefinierte SQL-Funktion.
UPDATE Employee
SET HireDate = DATEADD(DAY,+1,HireDate)

--19 Dir ist aufgefallen, dass häufig Abfragen über Firmenkunden und deren Rechnungsdetails verlangt werden. Um nicht immer wieder dieselben betroffenen Tabellen verknüpfenund entsprechend einschränken zu müssen, entscheidest du dich, eine View bereitzustellen, welche die gewünschten Informationen bereitstellt. Erstelle hierfür die View Firmenkunden mit folgenden Attributen: Company, InvoiceId, InvoiceDate und Total. Um zu sehen, ob deine View auch die gewünschten Ergebnisse ausgibt, führst du abschliessend das entsprechende Statement aus.
--Step 1
CREATE VIEW Firmenkunden AS
SELECT Company, InvoiceID, InvoiceDate, Total FROM Customer
    JOIN Invoice ON Invoice.CustomerId = Customer.CustomerId
--Step 2
SELECT * FROM Firmenkunden

--20 Als Datenbankadministrator sollst du dich ebenso als Mitarbeiter in die Firmendatenbank aufnehmen. Trage deine Personalien in die dafür vorgesehene Tabelle ein. Dein Vorgesetzter ist übrigens Andrew Adams.
INSERT INTO Employee (lastname, firstname, Title, ReportsTo) 
    VALUES ('Wandeler', 'Justin', 'Datenbankadministrator ', '1')

--21 Bei der Tabelle Album muss noch die Spalte HiddenTrack (boolean) mit dem Standardwert false implementiert werden.
ALTER TABLE Album
ADD HiddenTrack bit DEFAULT '0';

--22 Dein Chef möchte wissen, welche Firmenkunden schon zehn mal oder mehr etwas bestellt haben.Kunden ohne Firmennamen sind Privatkunden und dürfen bei dieser Auswertung nicht ausgewertet werden.Ausgabe: CustomerID, Company, Anzahl Bestellungen
SELECT Invoice.CustomerID, Customer.Company, COUNT(Invoice.InvoiceID) 'Anzahl Bestellungen' FROM Customer
    JOIN Invoice ON Customer.CustomerId = Invoice.CustomerId
WHERE Customer.Company IS NOT NULL
GROUP BY Invoice.CustomerID, Customer.Company 
HAVING COUNT(Invoice.InvoiceID) >= 10
ORDER BY Customer.Company ASC

--23 Gib mittels einer Mengenoperation alle Städte aus, wo es Kunden gibt, wohin jedoch keine Rechnungen verschickt werden.
SELECT City FROM Customer
EXCEPT
SELECT BillingCity FROM Invoice WHERE BillingCity IS NOT NULL

--24 Erstelle ein Backup der Datenbank und lade dieses in dieser Aufgabe hoch.
BACKUP DATABASE soundlib
TO DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\Backup\soundlib.bak' 