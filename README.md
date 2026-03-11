# Programowanie zorientowane na dane

Materiały wykorzystywane podczas zajęć *Programowanie zorientowane na dane*.

## Przygotowanie i uruchomienie środowiska (wersja uproszczona)

Logujemy się na serwer przygotowany do zajęć z adresem `IP` oraz (jeśli to
możliwe) tworzymy tunel

    ssh -i labsuser.pem ubuntu@IP -L 8888:127.0.0.1:8888

Pobieramy to repozytorium (jednorazowo)

    git clone https://github.com/piona/pznd

Inicjalizujemy środowisko wirtualnie z niezbędnymi pakietami

    cd pznd
    . ./pznd_init.sh

Uruchamiamy *JupyterLab* w wersji niezabezpieczonej (do tunelowania przez SSH,
środowisko dostępne pod adresem <http://localhost:8888>)

    pznd_jupyter

lub w wersji TLS chronionej hasłem do logowania (port musi być odblokowany
w AWS, środowisko dostępne pod adresem <https://IP:8888>, port może się różnić
jeśli 8888 był niedostępny)

    pznd_jupyter_tls [hasło]

## Przygotowanie środowiska

Logujemy się na serwer przygotowany do zajęć z adresem `IP` oraz tworzymy tunel

    ssh -i labsuser.pem ubuntu@IP -L 8888:127.0.0.1:8888

W katalogu domowym na serwerze należy utworzyć środowisko wirtualne oraz
zainstalować niezbędne pakiety

    cd
    python3 -m venv ve
    . ve/bin/activate
    pip install --upgrade pip
    pip install jupyter pandas matplotlib jupyter ipykernel

Pobieramy to repozytorium

    git clone https://github.com/piona/pznd

### Generowanie klucza i certyfikatu

Ten krok można pominąć jeśli wykorzystywany jest tunel SSH do zabezpieczenia
połączenia z *JupyterLab*.

Jeśli środowisko *JupyterLab* będzie udostępniane z wykorzystaniem protokołu TLS
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
    jupyter-lab --port 8888 --no-browser --ip='*' --IdentityProvider.token=''

Środowisko jest dostępne pod adresem <http://localhost:8888> na maszynie,
z której nawiązano połączenie oraz w sieci lokalnej.

### Uruchomienie środowiska w sesji TLS

W przypadku pracy bez tunelu SSH należy uruchomić środowisko z zabezpieczonym
połączeniem protokołem TLS (`TOKEN` posłuży za hasło dostępu, należy go zmienić)

    cd
    . ve/bin/activate
    cd pznd
    jupyter-lab --port 8888 --no-browser --ip='*' --IdentityProvider.token='TOKEN' --certfile ~/jupyter.crt --keyfile ~/jupyter.pem

Po nawiązaniu połączenia z <https://IP:8888> przed akceptacją certyfikatu należy
sprawdzić czy odcisk SHA-256 jest równy wcześniej wyliczonemu. Uwaga: `TOKEN`
może być widoczny dla innych użytkowników maszyny. Bezpieczniejsza metoda
ustawiana hasła jest zaimplementowana w `pznd_init.sh`.
