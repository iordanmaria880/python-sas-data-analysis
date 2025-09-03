
import pandas as pd

df = pd.read_csv(r"D:\PyCharm_Projects\.venv\Date_proiect\Date_proiect.csv", encoding="ISO-8859-1")
#Pandas incearca sa citeasca fisierul csv folosind implicit UTF-8, dar fișierul este codificat în alt format (ISO-8859-1)
print(df)
print(df.head())
print(df.columns)

#verificam daca avem valori lipsa
print(df.isna())
print(df.isna().sum())

#Lucrul cu series = o coloana individuala dintr-un data frame si cu data frame

#afisarea tuturor valorilor dintr-o coloana
print(df['Name'])
#SAU
print(df.Name)

#afisarea tipului de date dintr-o coloana
print(type(df['Name']))

#afisarea primelor 10 linii pentru coloana 'Name'
print(df.Name.head(10))

#afisarea ultimelor 10 linii pentru coloana 'Name'
print(df.Name.tail(10))

#afisarea valorilor pentru coloana 'Name'
print(df.Name.values)

#afisarea indexului pentru coloana 'Name'
print(df.Name.index)

#afisarea statisticilor descriptive pentru coloana 'Price'
print(df.Price)
print(df.Price.describe())

#afisarea hotelurilor cu preturi sub 100 euro
print(df[df.Price < 100])

#afisarea unor statistici despre numarul de review-uri

#afisarea hotelului cu cel mai mic nr de review-uri
print("Hotelul care are cel mai mic numar de review-uri este", df.Name[df.ReviewsCount.min()], ", avand", df.ReviewsCount.min(), "review.")

#afisarea hotelului cu cel mai mare nr de review-uri
index_max_reviews = df.ReviewsCount.idxmax()
hotel_name = df.Name.loc[index_max_reviews]
max_reviews = df.ReviewsCount.loc[index_max_reviews]
print(f"Hotelul care are cel mai mare numar de review-uri este {hotel_name}, avand {max_reviews} review-uri.")

#afisarea numarului mediu de review-uri
print("Numarul mediu de review-uri:", df.ReviewsCount.mean())

#afisarea medianei numarului de review-uri.
print("Mediana numarului de review-uri:", df.ReviewsCount.median())

#afisarea denumirilor tuturor hotelurilor (valorile de pe coloana 'Name')
print(df.iloc[:,0])

#afisarea datelor hotelului cu indexul 300
print(df.iloc[300])

#afisarea numelui (0) si pretului (2) pentru primele 2 inregistrari
print(df.iloc[[0,1], [0,2]])

#afisarea primelor 15 inregistrari
print(df.iloc[0:16])

#afisarea hotelurilor cu rating mai mare decat 8 si pretul sub 100 euro
print(df.loc[(df.Rating > 8) & (df.Price < 100)])

#afisarea inregistrarilor de la 10 la 20 dupa eticheta, si apoi dupa index
print(df.loc[10:20])
print(df.iloc[10:21])

