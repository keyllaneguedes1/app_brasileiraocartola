# 📊 Brasileirão Statistics App

Aplicativo mobile para análise de estatísticas dos jogadores do Brasileirão, com cálculo de pontuação fantasy baseado em scouts de defesa e ataque.

---

## 🚀 Objetivo
O app permite:
- Visualizar estatísticas dos jogadores (por rodada, temporada, posição).
- Calcular e exibir pontuação fantasy usando scouts.
- Comparar jogadores (clube vs liga).
- Monitorar evolução (últimas N rodadas).
- Ver impacto de scouts específicos (desarmes, finalizações, cartões, etc.).

---

## ⚙️ Arquitetura Geral

### 1. **Módulo de Análise (Python + Pandas)**
- Ingestão dos dados do repositório [caRtola].
- Normalização de scouts, posições, rodadas e jogadores.
- Função de cálculo de pontuação fantasy com base nos pesos definidos.
- Exportação em **CSV/JSON**:
  - `jogadores_rodadas.csv`
  - `jogadores_rodadas.json`

### 2. **Backend (FastAPI)**
- Carrega dados processados (CSV/JSON) em memória.
- Expõe endpoints para consulta.

### 3. **Frontend (Flutter)**
- Consome os endpoints da API.
- Telas:
  - Dashboard inicial
  - Lista de jogadores
  - Detalhes do jogador
  - Comparação entre jogadores
  - Rankings

---

## 📐 Modelo de Pontuação (Regra de Negócio)

### Scouts de Defesa
| Scout | Descrição            | Peso  |
|-------|----------------------|-------|
| DS    | Desarmes             | +1.2  |
| FC    | Falta cometida       | -0.3  |
| GC    | Gol contra           | -3.0  |
| CA    | Cartão amarelo       | -1.0  |
| CV    | Cartão vermelho      | -3.0  |
| SG    | Jogo sem sofrer gol* | +5.0  |
| DE    | Defesa difícil*      | +1.0  |
| DP    | Defesa de pênalti*   | +7.0  |
| GS    | Gol sofrido*         | -1.0  |
| PC    | Pênalti cometido     | -1.0  |

\* Apenas para Goleiro/Zagueiro/Lateral.

### Scouts de Ataque
| Scout | Descrição              | Peso  |
|-------|------------------------|-------|
| FS    | Falta sofrida          | +0.5  |
| PE    | Passe incompleto       | -0.1  |
| A     | Assistência            | +5.0  |
| FT    | Finalização na trave   | +3.0  |
| FD    | Finalização defendida  | +1.2  |
| FF    | Finalização para fora  | +0.8  |
| G     | Gol                    | +8.0  |
| I     | Impedimento            | -0.1  |
| PP    | Pênalti perdido        | -4.0  |
| PS    | Pênalti sofrido        | +1.0  |

---

## 🔌 Endpoints da API (FastAPI)

### Jogadores
- `GET /jogadores` → lista de jogadores (filtros: clube, posição, nome).
- `GET /jogadores/{id_jogador}` → detalhes do jogador.
- `GET /jogadores/{id_jogador}/rodadas` → histórico por rodada.

### Rankings
- `GET /ranking/rodada` → top jogadores por rodada.
- `GET /estatisticas/clube/{clube}` → overview do clube.

### Scouts Específicos
- `GET /scouts/ataque/top-assistencias`
- `GET /scouts/defesa/top-desarmes`
- `GET /scouts/ataque/top-gols`
- `GET /scouts/ataque/top-finalizacoes-perigosas`
- `GET /scouts/ataque/top-faltas-sofridas`
- `GET /scouts/defesa/top-faltas-cometidas`
- `GET /scouts/goleiros/top-defesas-dificeis`
- `GET /scouts/goleiros/top-penaltis-defendidos`
- `GET /scouts/defesa/top-jogos-sem-gol`

---

## 🛠️ Instalação e Execução

### Backend (FastAPI)
```bash
# Clonar repositório
git clone https://github.com/seu-repo/brasileirao-fantasy.git
cd backend

# Criar ambiente virtual
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows

# Instalar dependências
pip install -r requirements.txt

# Rodar servidor FastAPI
uvicorn main:app --reload

# No caso coloquei a api em servidor online disponível em:
👉 https://app-cartola-api.onrender.com

## 📱 Telas do App (Flutter)
- Splash Screen

- Dashboard Inicial (Top 5 jogadores do clube e da liga)

- Lista de Jogadores (busca + filtros)

Detalhe do Jogador (estatísticas + gráfico histórico)

- Comparação de Jogadores

- Rankings (rodada, temporada, clube)

# Observações: 
Backend simples com FastAPI, podendo evoluir para banco relacional.

Frontend em Flutter integrado via http ou dio.

Dados baseados no repositório caRtola.

Frontend (Flutter)

cd frontend
flutter pub get
flutter run
