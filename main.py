import re
import requests
import pandas as pd
import sqlalchemy
import dotenv

config = dotenv.dotenv_values()

google_drive_url = "https://drive.google.com/uc"
file_url = 'https://drive.google.com/file/d/1SzmRIwlpL5PrFuaUe_1TAcMV0HYHMD_b/view'
file_path_regex = re.compile('\/d\/([0-9a-zA-Z_]+)\/')
matches = file_path_regex.findall(file_url)
file_id = matches[0]


def download_google_document(file_id: str, destination: str ):
    params = dict(id=file_id, confirm=1, export='download')
    res = requests.get(google_drive_url, params=params, stream=True)
    with open(destination, 'wb') as file:
        file.write(res.content)


download_google_document(file_id, 'covid_19_data.csv')

df = pd.read_csv('covid_19_data.csv', parse_dates=['LastUpdate', 'ObservationDate'])
df.rename(columns={'SNo': 'serialNumber'}, inplace=True)
df.columns = list(map(lambda x: f'{x[0].lower()}{x[1:]}', df.columns))
df['observationDate'] = df['observationDate'].dt.date

DB_USER = config.get('DB_USER')
DB_PASSWORD = config.get('DB_PASSWORD')
DB_HOST = config.get('DB_HOST')
DB_PORT = config.get('DB_PORT', 5432)
DB_NAME = config.get('DB_NAME')
engine = sqlalchemy.create_engine(f'postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}')
print(df.head())

df.to_sql('covid_19_data', con=engine, if_exists='replace', index=False)