ETERM 6.1/MC6809

Programutvecklingsmiljö för Motorola MC6809 under Windows 95/98/NT4/2000
Utvecklad av Göteborgs Mikrovaror och CTH-Institutionen för Datorteknik

(R5- 00-03-26) Filer sparas nu korrekt även då "colored syntax" används
CMPY satte inte flaggor, fixat.


(R2-R4) Inga ändringar


Version 1 (99.08.24) (R1)
Småfix med texteditorn
Assembler detekterar nu för långa "brancher" korrekt


Version BETA (99.05.18)

En rad förbättringar från tidigare version (ETERM 6)
- Flera samtidiga terminalfönster, terminal öppnas nu
  med 'File | New | Terminal' därefter väljer du bland lediga portar
- Texteditor med 'färgad syntax' gör det lättare att stava rätt.
  Grön färg: giltigt symbolnamn i symbolfältet
  Blå färg: giltig 6809 mnemonic
  Röd färg: Giltig operand-syntax
Observera att editorn endast betraktar fälten för sig. Att respektive
fält är rätt färgat innebär alltså inte nödvändigtvis att
en, för instruktionen, giltig operand har angetts. Du får då felmeddelanden
vid assembleringen.

ETERM 6.1 sparar nu själv alla filer (temporärt) vid assemblering, du behöver
inte svara på någon fråga längre. Har du ändrat i en källtext får du däremot
frågan då du stänger filen...


Noter:
On-Line Hjälpsystemet är inte fullständigt färdigställt.


Göteborgs Mikrovaror
e-post:		support@gmv.nu
Internet:	http://www.gmv.nu

