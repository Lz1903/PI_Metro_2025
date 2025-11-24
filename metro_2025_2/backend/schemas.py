from pydantic import BaseModel
from datetime import date
from typing import Optional

class UsuarioSchema(BaseModel):
    nome: str
    email: str
    senha: str
    admin: bool
    codigo: str
    time: Optional[str] = None

    class Config:
        from_attributes = True

class MaterialSchema(BaseModel):
    id: Optional[str]= None
    nome: Optional[str]= None
    quantidade: Optional[int]= None
    unidade: Optional[str] = None
    limite_minimo: Optional[int]= None
    local: Optional[str]= None
    status: Optional[str] = None
    tipo: Optional[str] = None
    vencimento: Optional[date] = None

    class Config:
        from_attributes = True

class LoginSchema(BaseModel):
    email: str
    senha: str

    class Config:
        from_attribute = True

class InstrumentoSchema(BaseModel):
    id: str
    nome: str
    local: str
    calibracao: Optional[date] = None
