from fastapi import APIRouter, Depends, HTTPException
from schemas import MaterialSchema, InstrumentoSchema
from sqlalchemy.orm import Session
from dependencies import pegar_sessao, verificar_token
from models import Material, Instrumento, Usuario, Historico
from datetime import timezone

order_router = APIRouter(prefix="/pedidos", tags=["pedidos"])

def definir_status(qtd: int, limite_minimo: int)-> str:
    if qtd <= 0:
        return "Em falta"
    elif qtd <= limite_minimo:
        return "Pouco estoque"
    else:
        return "Disponível"

@order_router.post("/criar_material")
async def criar_material(material_schema: MaterialSchema, session: Session = Depends(pegar_sessao), usuario: Usuario = Depends(verificar_token)):
    if not usuario.admin:
        raise HTTPException(status_code=403, detail="Apenas administradores podem criar materiais")
    existente = session.query(Material).filter(Material.id==material_schema.id).first()
    status_automatico = definir_status(material_schema.quantidade, material_schema.limite_minimo)
    if existente:
        raise HTTPException(status_code=400, detail="Código de material já cadastrado")
    else:
        novo_material = Material(material_schema.id, material_schema.nome, material_schema.quantidade, material_schema.limite_minimo,material_schema.local, status_automatico, material_schema.tipo, material_schema.vencimento)
        session.add(novo_material)
        session.commit()
        return {"mensagem": "material cadastrado com sucesso!"}

@order_router.post("/criar_instrumento")
async def criar_instrumento(instrumento_schema: InstrumentoSchema, session: Session = Depends(pegar_sessao), usuario: Usuario = Depends(verificar_token)):
    if not usuario.admin:
        raise HTTPException(status_code=403, detail="Apenas administradores pode criar instrumentos")
    existente = session.query(Instrumento).filter(Instrumento.id==instrumento_schema.id).first()
    if existente:
        raise HTTPException(status_code=400, detail="Código de instrumento já cadastrado")
    else:
        novo_instrumento = Instrumento(instrumento_schema.id, instrumento_schema.nome, instrumento_schema.local, "Disponível",instrumento_schema.calibracao)
        session.add(novo_instrumento)
        session.commit()
        return {"mensagem": "instrumento cadastrado com sucesso!"}

@order_router.get("/listar_materiais")
async def listar_materiais(session: Session = Depends(pegar_sessao), usuario: Usuario = Depends(verificar_token)):
    materiais = session.query(Material).all()
    return [
        {
            "id": m.id,
            "nome": m.nome,
            "quantidade": m.quantidade,
            "local": m.local,
            "status": m.status,
            "tipo": m.tipo,
            "vencimento": m.vencimento,
            "limite_minimo": m.limite_minimo
        }
        for m in materiais
    ]

@order_router.get("/listar_instrumentos")
async def listar_instrumentos(session: Session = Depends(pegar_sessao), usuario: Usuario = Depends(verificar_token)):
    instrumentos = session.query(Instrumento).all()
    return [
        {
            "id": i.id,
            "nome": i.nome,
            "local": i.local,
            "status": i.status,
            "calibracao": i.calibracao
        }
        for i in instrumentos
    ]

@order_router.put("/editar_material/{id_material}")
async def editar_material(
    id_material: str,
    material_schema: MaterialSchema,
    session: Session = Depends(pegar_sessao),
    usuario: Usuario = Depends(verificar_token)
):
    if not usuario.admin:
        raise HTTPException(status_code=403, detail="Apenas administradores podem editar materiais")

    material = session.query(Material).filter(Material.id == id_material).first()
    if not material:
        raise HTTPException(status_code=404, detail="Material não encontrado")

    material.nome = material_schema.nome
    material.quantidade = material_schema.quantidade
    material.local = material_schema.local
    material.tipo = material_schema.tipo
    material.vencimento = material_schema.vencimento
    material.limite_minimo = material_schema.limite_minimo
    material.status = definir_status(material.quantidade, material.limite_minimo)

    session.commit()
    return {"mensagem": "Material atualizado com sucesso!"}

@order_router.put("/retirar_material/{id_material}/{quantidade}")
async def retirar_material(
    id_material: str,
    quantidade: int,
    session: Session = Depends(pegar_sessao),
    usuario: Usuario = Depends(verificar_token),
):
    material = session.query(Material).filter(Material.id == id_material).first()

    if not material:
        raise HTTPException(status_code=404, detail="Material não encontrado")

    if quantidade <= 0:
        raise HTTPException(status_code=400, detail="Quantidade inválida")

    if material.quantidade < quantidade:
        raise HTTPException(status_code=400, detail="Saldo insuficiente")

    # Subtrai
    material.quantidade -= quantidade

    # Atualiza status automaticamente
    material.status = definir_status(material.quantidade, material.limite_minimo)

    registro = Historico(
    item_id=material.id,
    nome_item=material.nome,
    quantidade=quantidade,
    usuario=usuario.nome, 
    tipo="material"
    )
    session.add(registro)

    session.commit()
    session.refresh(material)

    return {
        "mensagem": "Retirada realizada com sucesso",
        "novo_saldo": material.quantidade,
        "status": material.status,
        "material": material.nome
    }

@order_router.put("/retirar_instrumento/{id}")
async def retirar_instrumento(
    id: str,
    session: Session = Depends(pegar_sessao),
    usuario: Usuario = Depends(verificar_token)
):
    instrumento = session.query(Instrumento).filter(Instrumento.id == id).first()

    if not instrumento:
        raise HTTPException(status_code=404, detail="Instrumento não encontrado")

    if instrumento.status == "Em uso":
        raise HTTPException(status_code=400, detail="Este instrumento já está em uso")

    instrumento.status = "Em uso"

    registro = Historico(
        item_id=instrumento.id,
        nome_item=instrumento.nome,
        quantidade=None,
        usuario=usuario.nome,
        tipo="instrumento"
    )

    session.add(registro)
    session.commit()
    session.refresh(instrumento)

    return {
        "mensagem": "Instrumento retirado com sucesso!",
        "id": instrumento.id,
        "status": instrumento.status
    }



@order_router.put("/devolver_instrumento/{id}")
async def devolver_instrumento(id: str, session: Session = Depends(pegar_sessao)):
    instrumento = session.query(Instrumento).filter(Instrumento.id == id).first()

    if not instrumento:
        raise HTTPException(status_code=404, detail="Instrumento não encontrado")

    if instrumento.status == "Disponível":
        raise HTTPException(status_code=400, detail="Este instrumento não está em uso")

    instrumento.status = "Disponível"
    session.commit()
    session.refresh(instrumento)

    return {
        "mensagem": "Instrumento devolvido com sucesso!",
        "id": instrumento.id,
        "status": instrumento.status
    }

@order_router.get("/historico")
async def listar_historico(session: Session = Depends(pegar_sessao), usuario: Usuario = Depends(verificar_token)):
    historico = session.query(Historico).order_by(Historico.data_hora.desc()).all()
    
    return [
        {
            "id": h.id,
            "item_id": h.item_id,
            "nome_item": h.nome_item,
            "quantidade": h.quantidade,
            "usuario": h.usuario,
            "tipo": h.tipo,
            "data_hora": h.data_hora.strftime("%Y-%m-%d %H:%M:%S")
        }
        for h in historico
    ]

