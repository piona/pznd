#!/bin/bash
# - create (if needed) and activate virtual environment
# - export functions pznd_jupyter and pznd_jupyter_tls
#   to start JupyterLab over HTTP and HTTPS
# run: . ./pznd_init.sh

# virtual environment directory
VENV_DIR="$HOME/ve"

# check venv
if ! python3 -m venv --help > /dev/null 2>&1; then
    echo "❌ error: python3-venv not installed"
    echo "   fix with sudo apt update && sudo apt install python3-venv -y"
    return 1 2>/dev/null || exit 1
fi

# check if ve is already initialized
if [ ! -d "$VENV_DIR" ]; then
    echo "🚀 creating virtual environment..."
    python3 -m venv "$VENV_DIR"
    source "$VENV_DIR/bin/activate"
    echo "📦 installing packages..."
    pip install --upgrade pip -q
    pip install pandas matplotlib jupyter ipykernel -q
    echo "✅ virtual environment initialized"
else
    echo "ℹ️  activating existing virtual environment"
    source "$VENV_DIR/bin/activate"
fi

JLAB_VER=$(jupyter-lab --version 2>/dev/null)

# info about packages
python3 << EOF
try:
    import sys, pandas as pd, numpy as np, matplotlib, ipykernel
    sv = sys.version_info
    print(f"🤖 Python:     {sv.major}.{sv.minor}.{sv.minor}")
    print(f"🧪 JupyterLab: ${JLAB_VER}")
    print(f"🪐 Jupyter:    {ipykernel.__version__} (kernel)")
    print(f"🔢 NumPy:      {np.__version__}")
    print(f"📈 Matplotlib: {matplotlib.__version__}")
    print(f"📊 Pandas:     {pd.__version__}")
    print("🐍 virtual environment initialized")
except ImportError as e:
    print(f"⚠️  error: package not installed {e}")
except Exception as e:
    print(f"❌ error: {e}")
EOF

# start JupyterLab over HTTP (port 8888)
pznd_jupyter() {
    if [ -z "$VIRTUAL_ENV" ]; then
        echo "⚠️  activating virtual environment..."
        source "$VENV_DIR/bin/activate"
    fi
    echo "🧪 starting JupyterLab"
    echo "🌐 http://localhost:8888 or http://127.0.0.1:8888"
    jupyter-lab --port 8888 \
                --no-browser --ip='*' \
                --IdentityProvider.token='' \
                --PasswordIdentityProvider.hashed_password="$HASHED_PWD" \
                --log-level='WARN'
}

export -f pznd_jupyter

# start JupyterLab over HTTPS (first free port starting from 8888)
pznd_jupyter_tls() {
    local PASSWORD=$1
    local CERT_FILE="$HOME/jupyter.crt"
    local KEY_FILE="$HOME/jupyter.pem"
    local START_PORT=8888
    local PORT=$START_PORT

    # look for password
    if [ -z "$PASSWORD" ]; then
        echo "❌ error: password missing, pznd_jupyter_tls 'your password'"
        return 1
    fi

    # try to find free port
    while lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null ; do
        echo "⚠️ info: port $PORT is not free, checking $((PORT+1))"
        PORT=$((PORT+1))
    done

    # generate private key and certificate
    if [ ! -f "$CERT_FILE" ] || [ ! -f "$KEY_FILE" ]; then
        echo "🔐 generating private key and certificate..."
        openssl req -x509 -nodes -days 365 -newkey ec:<(openssl ecparam -name P-256) \
            -keyout "$KEY_FILE" -out "$CERT_FILE" -subj "/CN=jupyter" 2>/dev/null
    fi

    # prepare password
    export JUPYTER_PWD=$PASSWORD
    local HASHED_PWD=$(python3 -c "import os; from jupyter_server.auth import passwd; print(passwd(os.environ['JUPYTER_PWD']))")
    unset JUPYTER_PWD

    # start virtual environment
    if [ -z "$VIRTUAL_ENV" ]; then
        echo "⚠️  activating virtual environment..."
        source "$VENV_DIR/bin/activate"
    fi

    echo "🧪 starting JupyterLab"

    # show fingerprint
    echo "📜 fingerprint (SHA-256):" $(openssl x509 -fingerprint -sha256 -in "$CERT_FILE" -noout | cut -d'=' -f2 | tr -d ':')
    echo "🌐 https://localhost:$PORT or https://127.0.0.1:$PORT"
    echo "🌐 https://$(curl -s ifconfig.me):$PORT (public)"

    jupyter-lab --port "$PORT" \
                --no-browser \
                --ip='*' \
                --certfile="$CERT_FILE" \
                --keyfile="$KEY_FILE" \
                --IdentityProvider.token='' \
                --PasswordIdentityProvider.hashed_password="$HASHED_PWD" \
                --log-level='WARN'
}

export -f pznd_jupyter_tls

echo "✅ ready: run 'pznd_jupyter' or 'pznd_jupyter_tls your-password' to start"
