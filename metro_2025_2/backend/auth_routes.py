from fastapi import APIRouter, Depends, HTTPException
from models import Usuario
from dependencies import pegar_sessao, verificar_token
from main import bcrypt_context, ALGORITHM, ACCESS_TOKEN_EXPIRE_MINUTES, SECRET_KEY
from schemas import UsuarioSchema, LoginSchema
from sqlalchemy.orm import Session
from jose import jwt, JWTError
from datetime import datetime, timedelta, timezone

auth_router = APIRouter(prefix="/auth", tags=["auth"])

def criar_token(id_usuario, duracao_token=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)):
    data_expiracao = datetime.now(timezone.utc) + duracao_token
    dic_info = {"sub": str(id_usuario), "exp": data_expiracao}
    jwt_codificado = jwt.encode(dic_info, SECRET_KEY, ALGORITHM)
    return jwt_codificado

def autenticar_usuario(email, senha, session):
    usuario = session.query(Usuario).filter(Usuario.email==email).first()
    if not usuario:
        return False
    elif not bcrypt_context.verify(senha, usuario.senha):
        return False
    return usuario

@auth_router.get("/")
async def home():
    return {"mensagem": "Rota padrão de autenticacao", "autenticado": False}

@auth_router.post("/criar_conta")
async def criar_conta(usuario_schema: UsuarioSchema, session: Session = Depends(pegar_sessao)):
    usuario = session.query(Usuario).filter(Usuario.email==usuario_schema.email).first()
    if usuario:
        raise HTTPException(status_code=400, detail="E-mail do usuario já cadastrado")
    codigo_digitado = usuario_schema.codigo.strip()

    if not codigo_digitado.isdigit() or len(codigo_digitado) != 6:
        raise HTTPException(
            status_code=400,
            detail="O código deve possuir exatamente 6 dígitos numéricos"
        )
    codigo_final = f"r{codigo_digitado}"

    codigo_existente = session.query(Usuario).filter(Usuario.codigo == codigo_final).first()
    if codigo_existente:
        raise HTTPException(status_code=400, detail="Já existe um usuário com este código.")
    
    senha_hash = bcrypt_context.hash(usuario_schema.senha)

    novo_usuario = Usuario(
        nome=usuario_schema.nome,
        email=usuario_schema.email,
        senha=senha_hash,
        admin=usuario_schema.admin,
        codigo=codigo_final,
        time=usuario_schema.time
    )
    session.add(novo_usuario)
    session.commit()

    return {"mensagem": "Usuário cadastrado com sucesso"}
    
@auth_router.post("/login")
async def login(login_schema: LoginSchema, session: Session = Depends(pegar_sessao)):
    usuario = autenticar_usuario(login_schema.email, login_schema.senha, session)
    if not usuario:
        raise HTTPException(status_code=400, detail= "Usuario não encontrado ou credenciais inválidas")
    else:
        access_token = criar_token(usuario.id)
        refresh_token = criar_token(usuario.id, duracao_token=timedelta(days=7))
        return {"access_token": access_token,
                "refresh_token": refresh_token,
                "token_type": "Bearer",
                "admin": usuario.admin,
                "nome": usuario.nome,
                "email": usuario.email
                }

@auth_router.get("/refresh")
async def use_refresh_token(usuario: Usuario = Depends(verificar_token)):
    access_token = criar_token(usuario.id)
    return {
        "access_token": access_token,
        "token_type": "Bearer"
        }

@auth_router.get("/listar_usuarios")
async def listar_usuarios(session: Session = Depends(pegar_sessao), usuario: Usuario = Depends(verificar_token)):    
    usuarios = session.query(Usuario).all()
    
    return [
        {
            "id": u.id,
            "nome": u.nome,
            "email": u.email,
            "admin": u.admin,
            "codigo": u.codigo,
            "time": u.time if u.time else "Sem Equipe"
        }
        for u in usuarios
    ]

@auth_router.put("/editar_usuario/{id_usuario}")
async def editar_usuario(
    id_usuario: int, 
    usuario_schema: UsuarioSchema, 
    session: Session = Depends(pegar_sessao),
    usuario_logado: Usuario = Depends(verificar_token)
):
    if not usuario_logado.admin:
         raise HTTPException(status_code=403, detail="Apenas admins podem editar usuários")

    usuario_alvo = session.query(Usuario).filter(Usuario.id == id_usuario).first()
    
    if not usuario_alvo:
        raise HTTPException(status_code=404, detail="Usuário não encontrado")

    usuario_alvo.nome = usuario_schema.nome
    usuario_alvo.email = usuario_schema.email
    
    if usuario_schema.senha and usuario_schema.senha != usuario_alvo.senha:
         usuario_alvo.senha = bcrypt_context.hash(usuario_schema.senha)
         
    usuario_alvo.admin = usuario_schema.admin
    usuario_alvo.codigo = usuario_schema.codigo
    usuario_alvo.time = usuario_schema.time

    session.commit()
    return {"mensagem": "Usuário atualizado com sucesso"}

@auth_router.delete("/excluir_usuario/{id_usuario}")
async def excluir_usuario(
    id_usuario: int, 
    session: Session = Depends(pegar_sessao),
    usuario_logado: Usuario = Depends(verificar_token)
):
    if not usuario_logado.admin:
         raise HTTPException(status_code=403, detail="Apenas admins podem excluir usuários")

    usuario_alvo = session.query(Usuario).filter(Usuario.id == id_usuario).first()
    
    if not usuario_alvo:
        raise HTTPException(status_code=404, detail="Usuário não encontrado")
        
    session.delete(usuario_alvo)
    session.commit()
    return {"mensagem": "Usuário excluído com sucesso"}