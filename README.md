# Programowanie zorientowane na dane

Materiały wykorzystywane podczas zajęć *Programowanie zorientowane na dane*.

## Przygotowanie środowiska

Logujemy się na serwer przygotowany do zajęć z adresem `IP` oraz tworzymy tunel

    ssh -i labsuser.pem ubuntu@IP -L 8888:localhost:8888

W katalogu domowym na serwerze należy utworzyć środowisko wirtualne oraz zainstalować niezbędne pakiety

    cd
    python3 -m venv ve
    . ve/bin/activate
    pip install jupyter matplotlib pandas ipympl scipy pooch sympy

Pobieramy to repozytorium

    git clone https://github.com/piona/pznd

### Generowanie klucza i certyfikatu

Ten krok można pominąć jeśli wykorzystywany jest tunel SSH do zabezpieczenia
połączenia z *Jupyter*.

Jeśli środowisko *Jupyter* będzie udostępniane z wykorzystaniem protokołu TLS
należy wygenerować klucz `jupyter.pem` oraz certyfikat `jupyter.crt`

    openssl req -x509 -nodes -days 365 -newkey ec:<(openssl ecparam -name P-256) -keyout ~/jupyter.pem -out ~/jupyter.crt -subj /CN=jupyter

Do sprawdzenia poprawności połączenia w przeglądarce (wytworzony certyfikat
będzie niezaufany) niezbędne jest sprawdzenie odcisku SHA-256, który można
wyliczyć poleceniem

    openssl x509 -fingerprint -sha256 -in jupyter.crt -noout

## Uruchomienie środowiska

Jeśli nie jesteśmy połączeni to logujemy się na serwer przygotowany do zajęć
z adresem `IP` oraz tworzymy tunel

    ssh -i labsuser.pem ubuntu@IP -L 8888:localhost:8888

Uruchamiamy środowisko *Jupyter* (zalecane jest wykonanie poleceń w sesji
aplikacji `tmux`)

    cd
    . ve/bin/activate
    cd pznd
    jupyter-lab --port 8888 --no-browser --ip='*' --NotebookApp.token='' --NotebookApp.password=''

Środowisko jest dostępne pod adresem <http://localhost:8888> na maszynie,
z której nawiązano połączenie oraz w sieci lokalnej.

### Uruchomienie środowiska w sesji TLS

W przypadku pracy bez tunelu SSH należy uruchomić środowisko z zabezpieczonym
połączeniem protokołem TLS (`TOKEN` posłuży za hasło dostępu, należy go zmienić)

    cd
    . ve/bin/activate
    cd pznd
    jupyter-lab --port 8888 --no-browser --ip='*' --NotebookApp.token='TOKEN' --NotebookApp.password='' --certfile ~/jupyter.crt --keyfile ~/jupyter.pem

Po nawiązaniu połączenia z <https://IP:8888> przed akceptacją certyfikatu należy
sprawdzić czy odcisk SHA-256 jest równy wcześniej wyliczonemu.

