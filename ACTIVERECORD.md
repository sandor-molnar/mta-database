## Mi ez?
Az ActiveRecord (továbbiakban AR), egy adatbázis táblát kezelő osztály.  
Segítségével könnyedén, SQL nélkül tudjuk kezelni az adatbázist.  
Szükséges hozzá a **database** csomag.  

## Létrehozás
Elsőként létre kell hoznunk egy táblát az adatbázisban. Legyen ez most `test_table`.  
Ha ez megvan, hozzuk létre az osztályt.  
A fájl és osztály neve mindig a tábla nevét kapja. Jelen esetben: `TestTable.class.lua` (CamelCase)  
``` lua
class 'TestTable' ('ActiveRecord') {
    table = 'test_table', -- Tábla pontos neve
}
TestTable.__class = TestTable -- Ez mindig legyen itt.
```
Ezzel már képesek vagyunk használni a test_table tábla adatait.

## Használható metódusok
### findOne(id)
Segítségével a megadott `primaryKey` átadásával tudunk keresni.  
Visszatérése mindig a létrehozott osztály példánya vagy `nil`.  
```lua
local row = TestTable():findOne(1)
```

### findAll(condition)
Segítségével egy megadott feltétel alapján tudunk mezőkre.  
Midig az összes elemet vissza adja.  
```lua
local rows = TestTable():findAll({id = {1,2,3}}) -- Visszadja az 1,2 és 3 ID-vel rendelkező sort.
```

### getQuery()
Vissza ad egy `Query`-t, amivel összetettebb lekérdezést lehet végezni.  
A Query már tartalmazni fogja a `select` és a `from` értékeket.  
```lua
local q = TestTable():getQuery()
q:where({id = {1,2,3}})
q:orWhere({id = 4})
```

### loadByQuery(queryResult, returnOne = false)
A `getQuery` (vagy síma query) értékét lehet átadni `one` vagy `all`-ban.  
A visszatérési értéke nil/model, ha 1 result van átadva (tehát queryResult['id'] alakban van, nem queryResult[1]['id']), tömb ha több érték van átadva (akkor is ha üres tömb).  
Ez alól kivétel, ha a `returnOne` értéke `true`.  
Alapból false értéke van, de ha csak 1 értéket kapott, akkor 1 értékkel is tér vissza.  
```lua
local q = TestTable():getQuery()
q:where({id = {1,2,3}})
q:orWhere({id = 4})

local row = TestTable():loadByQuery(q:all(), true) -- nil
```

### save(force)
Segítségével menthetjük a módosításokat az adott példányon.  
Force esetén akkor is le futtatja az SQL-t, ha nem változott semmi.  
Mentésnél (változás vagy force) ha új érték, kitölti a created_at, updated_at mezőket.  
Ha csak frissítés, akkor csak az updated_at mezőt frissíti. 
```lua
local row = TestTable():findOne(1)
row.value = 2 -- value oszlop
row:save() -- Ekkor ha mondjuk a value oszlop értéke az 1-es ID-nél 10 volt, most 2-re változik (UPDATE ... SET value = 2 WHERE ...)

-- Nem csak meglévőt menthetünk
local newRow = TestTable()
newRow.value = 3
newRow = newRow:save() -- Beszúrja adatbázisba a megadott értékekkel, majd visszadja autómatikusan a példányt.
```
  
Mentésnél csak azokat az adatokat menti, amiknél változás történt.  
Ha figyelmen kívül akarjuk hagyni ezt a változás figyelést, esetleg minden adatot menteni akarunk, vagy az updated_at részt akarjuk frissíteni akkor megadhatjuk a save metódusnak a force paramétert.  
```lua
row:save(true)
```

### delete()
Törli a megadott példányt
```lua
local row = TestTable():findOne(1)
row:delete()
```

### deleteOne(id)
Hasonlóan a find-hoz, a megadott PK-t törli.
```lua
TestTable():deleteOne(1)
```

### deleteAll(condition)
Hasonlóan a find-hoz, a megadott feltételnek megfelelő sorokat törli.
```lua
TestTable():deleteAll({id = {1,2,3}})
```

### updateOne(id, values)
Hasonlóan a find-hoz, a megadott PK-t frissíi a megadott értékkel.
```lua
TestTable():updateOne(1, {value = 3})
```

### updateAll(condition, values)
Hasonlóan a find-hoz, a megadott feltételnek megfelelő sorokat frissíti.
```lua
TestTable():updateAll({id = {1,2,3}}, {value = 3})
```

### refresh()
Újra tölti a modelt.  
**Új rekordok esetében már lefut, hogy a model tartalmazza az `id` (primaryKey) mezőt is.**
``` lua
local test = TestTable():findOne(1) -- A `value` legyen itt most 3
test.value = 100
test = test:refresh() 
outputDebugString('Érték: '..test.value) -- Érték: 3
```

## "Behavior" metódusok
A Behavior metódusokat az osztályban felülírva kapják meg hatásukat.
```lua
class 'TestTable' ('ActiveRecord') {
    table = 'test_table', -- Tábla pontos neve
    
    behaviorNeve = function(self)

    end,
}
TestTable.__class = TestTable -- Ez mindig legyen itt.
```
### beforeSave()
Akkor hívódik meg, amikor az adatbázis sor mentve van. Ez alol kivétel ha új sor, mert akkor betöltéskor hívodik csak meg.

### afterSave()
Hasonló az `afterInsert` és az `afterUpdate` behaviorokhoz, viszont ez új és meglévőnél is lefut mentéskor.

### beforeDelete()
Törlés előtt (delete metódus) fut let

### afterDelete()
Törlés után fut le. Hasznos itt törölni az osztályhoz tartozó objecteket, elementeket.

### beforeUpdate()
Már létező model mentése előtt fut le. (Konkrétan az SQL futtatás előtt)

### afterUpdate()
`beforeUpdate` és SQL futtatás után fut le közvetlen.

### beforeInsert()
Új model beszúrása előtt fut le. (Konkrétan az SQL futtatás előtt)

### afterInsert()
`beforeInsert` és SQL futtatás után fut le közvetlen.


