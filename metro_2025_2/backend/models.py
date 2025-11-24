from sqlalchemy import create_engine, Column, String, Integer, Boolean, Float, ForeignKey, DateTime
from sqlalchemy.orm import declarative_base, sessionmaker
from datetime import datetime

db  = create_engine("sqlite:///banco.db")

Base = declarative_base()

class Usuario(Base):
    __tablename__ = "usuarios"

    id = Column("id", Integer, autoincrement=True, primary_key=True)
    nome = Column("nome", String, nullable=False)
    email = Column("email", String, nullable=False)
    senha = Column("senha", String, nullable=False)
    admin = Column("admin", Boolean, nullable=False)
    codigo = Column("codigo", String(7), unique=True, nullable= False)
    time = Column("time", String, nullable=True)

    def __init__(self, nome, email, senha, admin, codigo, time=None):
        self.nome = nome
        self.email = email
        self. senha = senha
        self.admin = admin
        self.codigo = codigo
        self.time = time

class Material(Base):
    __tablename__ = "materiais"

    id = Column("id", String, primary_key=True)
    nome = Column("nome", String, nullable=False)
    quantidade = Column("quantidade", Integer, nullable=False)
    unidade = Column("unidade", String, nullable=False)
    limite_minimo = Column("limite_minimo", Integer, nullable=False)
    local = Column("local", String, nullable=False)
    status = Column("status", String)
    tipo = Column("tipo", String, nullable=False)
    vencimento = Column("vencimento", DateTime)

    def __init__(self, id, nome, quantidade, unidade, limite_minimo,local, status, tipo, vencimento):
        self.id = id
        self.nome = nome
        self.quantidade = quantidade
        self.unidade = unidade
        self.limite_minimo = limite_minimo
        self.local = local
        self.status = status
        self.tipo = tipo
        self.vencimento = vencimento

class Instrumento(Base):
    __tablename__ = "instrumentos"

    id = Column("id", String, primary_key=True)
    nome = Column("nome", String, nullable=False)
    local = Column("local", String, nullable=False)
    status = Column("status", String, nullable=False)
    calibracao = Column("calibacao", DateTime)
    usuario_id = Column("usuario_id", String, nullable=True)

    def __init__(self, id, nome, local, status, calibracao, usuario_id=None):
        self.id = id
        self.nome = nome
        self.local = local
        self.status = status
        self.calibracao = calibracao
        self.usuario_id = usuario_id

class Historico(Base):
    __tablename__ = "historico"

    id = Column(Integer, primary_key=True, autoincrement=True)
    item_id = Column(String, nullable=False)
    nome_item = Column(String, nullable=False)
    quantidade = Column(Integer, nullable=True)
    usuario = Column(String, nullable=False)
    data_hora = Column(DateTime, default=lambda: datetime.now())
    tipo = Column(String, nullable=False)

if __name__ == "__main__":
    Base.metadata.create_all(db)
    print("Banco de dados e tabelas criados com sucesso!")