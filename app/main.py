from fastapi import FastAPI, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from jose import JWTError, jwt
from passlib.context import CryptContext
from datetime import datetime, timedelta
from prometheus_client import Counter, generate_latest
from fastapi.responses import PlainTextResponse
import uvicorn

app = FastAPI(title="Auth/SSO Service")

SECRET_KEY = "your-secret-key-change-in-production"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

login_counter = Counter("login_attempts_total", "Total login attempts")
success_counter = Counter("login_success_total", "Successful logins")

fake_users = {
    "admin": {"username": "admin", "password": pwd_context.hash("admin123")}
}

def create_token(data: dict):
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    data.update({"exp": expire})
    return jwt.encode(data, SECRET_KEY, algorithm=ALGORITHM)

@app.post("/token")
def login(form_data: OAuth2PasswordRequestForm = Depends()):
    login_counter.inc()
    user = fake_users.get(form_data.username)
    if not user or not pwd_context.verify(form_data.password, user["password"]):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    success_counter.inc()
    token = create_token({"sub": form_data.username})
    return {"access_token": token, "token_type": "bearer"}

@app.get("/health")
def health():
    return {"status": "healthy"}

@app.get("/metrics", response_class=PlainTextResponse)
def metrics():
    return generate_latest()

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)