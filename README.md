# Adatbázis osztályok MTA:SA játékszerverhez
### Tartalmazza
- **Query kezelő**: segítségével nem kell külön SQL-t írni, elég egy rövidebb és egyszerűbb kódot használnunk.
- **ActiveRecord** segítségével az adatbázis táblákat tudjuk egyszerűen, és tematikusan kezelni. (Lásd: [ActiveRecord leírás](https://github.com/sanyisasha/mta-database/blob/master/ACTIVERECORD.md)

### Telepítés
- A letöltött forrás tartalmát másoljuk egy tetszőleges mappába a `resources`-en belül.  
- Egészítsük ki a resource `meta.xml` fájlját a forrásban lévő meta.xml-el.  
- Töltsük le a következő repót: [mta-mysql](https://github.com/sanyisasha/mta-mysql), és kövessük az ott leírtakat
- `refresh` majd `start mta-database`

### Használata
Használnálatra javasolt az [mta-package-manager]() használata.  
Segítségével könnyedén tudjuk másolgatni a resource-öket.  
1-2 osztály már ott is megtalálható. Akár felül is írható az ott lévő fájlokkal. *ActiveRecord ott még nincs, így azt külön fel kell vennünk*  
Általánosságban pedig a meta.xml-ben legyen benne a `database` és az `utils` mappa tartalma, és az `example.s.lua`-hoz hasonlóan használhatóak.

### Leírások
- [Class](https://github.com/sanyisasha/mta-database/blob/master/CLASS.md)
- [Database és Query](https://github.com/sanyisasha/mta-database/blob/master/DATABASE.md)
- [ActiveRecord](https://github.com/sanyisasha/mta-database/blob/master/ACTIVERECORD.md)
