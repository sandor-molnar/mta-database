`database/Query.class.lua`  
Query segítségével lekérdezést és egyéb sql parancsot tudunk végrehajtani. 
# Select
Lekérdezésekhez.  
A többivel ellentétben, ez külön osztályt kapott összetetsége végett.  
Átláthatóság miatt példányosítsuk a következő módon:  
``` lua
-- Visszadja a database/SelectQuery.class.lua osztály példányát.
local q = Query():select({'id', 'username'})
-- Vagy régi megoldásként:
local q = SelectQuery({'id', 'username'})
```
Lehetőségek:  
### where/andWhere(conditions)
Tömbként átadhatunk egy listát a where feltételekről.  
Az `andWhere` csak átláthatóság végett van. (Például hosszú kódnál ha andWhere-t használunk, láthatjuk hogy lesz előtte egy where)
``` lua
q:where({
    ['username'] = 'test',
    -- Vagy használható idézőjel nélkül, ha egyben van
    id = 1,
    -- Összetetebb WHERE
    {'NOT IN', 'id', {1,2,3}}, -- WHERE ... AND `id` NOT IN (1,2,3)
    {'>=', 'id', 1} -- WHERE ... AND `id` >= '1'
})

-- andWhere
q:andWhere({
    id = 2
})
```

### orWhere(conditions)
Vagy kapcsolat hozzáadása. Fontos a hozzáadási sorrend.  
Előtte szükséges mindenképp egy `where`.  
``` lua
q:where({
    username = 'test1'
})
q:orWhere({
    username = 'test2',
})
-- WHERE `username` = "test1" OR `username` = "test2"
```

### from(table)
Tábla megadása.  
Síma `Query` esetén kötelező mező.
``` lua
q:from('users')
```

### select(values)
Alapértelmezetten `*`.  
Megadja hogy mely mezőket akarjuk lekérdezni.  
``` lua
q:select({'id', 'username'})
-- Vagy ha mindent lekérdezünk
q:select()
```

### orderBy(orders)
Rendezés megadása.  
Több rendezés is lehetséges. [Példa](https://stackoverflow.com/a/514947)  
Rendezhető a következőkkel:
- Query.SORT_DESC
- Query.SORT_ASC
``` lua
q:orderBy({username = Query.SORT_DESC, id = Query.SORT_ASC})
```

### limit(amount)
Limitálja a lekérdezhető mezők mennyiségét.  
``` lua
q:limit(10) -- all() esetén maximum 10 értéket ad vissza
```

### groupBy(groups)
Csoportosítás. [Részletek](https://www.w3schools.com/sql/sql_groupby.asp)
``` lua
q:groupBy('serial')
```

### all
Minden lehetséges értéket visszad
``` lua
local result = Query()...:all()
outputDebugString(result[1]['id'])
```

### one
Csak egy értéket ad vissza **ÉS** reseteli a result-ot! (Tehát nem `result[1]['id']` hanem `result['id']`)  
``` lua
local result = Query()...:one()
outputDebugString(result['id'])
```

# insert (table, values)
Segítségével sort tudunk beszúrni adatbázisba.    
``` lua
Query():insert('users', {
    username = 'test',
    name = 'test2'
})
```

# update (table, values, conditions)
Segítségével sort tudunk frissíteni.   
A **condition** értéke lehet szám is, ekkor ID-t fog behelyettesíteni.  
``` lua
Query():update('users', {
    username = 'test',
    name = 'test2',
}, {
    id = 1,
})
```

# delete(table, conditions)
Segítségével sort tudunk törölni. 
``` lua
Query():delete('users', {
    id = 1,
})
```
