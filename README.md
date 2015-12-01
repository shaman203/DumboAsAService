# DumboAsAService 

## PredictLikes - blogok "like-profil" alapján klaszterezése és a csoportosítás vizualizációja

A megadott adathalmazból kizárólag a `trainUsers.json` állományt használtunk fel a feladat megoldásához. Először kinyerjük
MapReduce-szal azon blogpárokat melyeknek van közös lájkolójuk, és a pároshoz hozzárendeljük ezen lájkolók pontos számát.

- A Map fázisban minden felfedezett `(blog1, blog2)` kulcshoz egy egyest rendelünk. Mivel a bemeneti adat minden sora egy konkrét
felhasználó lájkolásait rögzíti, ha felhasználó n darab blogposztot lájkolt, a sor feldolgozása n*(n-1)/2 kulcs-érték pár emittálását
eredményezi. Fontos megjegyezni hogy ki kell kényszeríteni a kulcspárok elemeinek egyértelmű sorrendjét, hogy a Reduce fázisban történő
számlálások helyesen hajtódjanak végre, tehát ne történjen meg például a következő eset:
`(blog1, blog2), 1`
`(blog2, blog1), 1`

- A Reduce fázisban történik meg a kulcsok szerinti összegzés.

Végezetül egy olyan adatszerkezetet kapunk, amely egy olyan irányítatlan gráfot reprezentál, melynek csúcsai blogposztok, és két csúcs
között futó él súlya a csúcsok közös lájkjainak száma.

Az így keletkező adatmennyiség már kezelhető R-ben is. Az előbb említett gráfunkon az `igraph` gráfalgoritmusokat tartalmazó könyvtár `fastgreedy.community` algoritmusával közösségeket kerestünk, majd ezt vizualizáltuk az alábbi ábrán:
