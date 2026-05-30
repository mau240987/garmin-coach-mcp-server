# garmin-mcp-server (Python)

MCP Server per Garmin Connect — legge attività, dati salute, e carica workout/piani di allenamento strutturati su Garmin Connect.

Usa la libreria **garminconnect** Python (testata e validata con dati reali).

---

## Tools disponibili (9)

| Tool | Tipo | Descrizione |
|---|---|---|
| `get_activities` | Read | Lista attività recenti con distanza, ritmo, FC, calorie |
| `get_activity_details` | Read | Dettaglio completo: split, lap, dinamiche di corsa |
| `get_health_summary` | Read | Steps, resting HR, HRV, stress, sonno, body battery, SpO2, training readiness |
| `get_training_status` | Read | Volume settimanale: km totali, numero sessioni, passo medio |
| `get_workouts` | Read | Lista workout salvati su Garmin Connect |
| `push_workout` | Write | Crea un workout strutturato con doppio target (ritmo + FC) |
| `push_training_plan` | Write | Carica un piano multi-giorno sul calendario Garmin |
| `delete_workout` | Write | Cancella un workout specifico |
| `delete_plan_workouts` | Write | Cancella tutti i workout di un piano (per nome) |

---

## Quick start

### Prerequisiti

```bash
pip install mcp garminconnect pydantic
```

### Modalità 1 — Claude Desktop (stdio)

Aggiungi a `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "garmin": {
      "command": "python",
      "args": ["/path/to/garmin_mcp_server.py"],
      "env": {
        "GARMIN_EMAIL": "tua@email.com",
        "GARMIN_PASSWORD": "tuapassword"
      }
    }
  }
}
```

### Modalità 2 — Claude Code

```bash
export GARMIN_EMAIL="tua@email.com"
export GARMIN_PASSWORD="tuapassword"
claude mcp add garmin -- python /path/to/garmin_mcp_server.py
```

### Modalità 3 — HTTP (client remoti, claude.ai)

```bash
export GARMIN_EMAIL="tua@email.com"
export GARMIN_PASSWORD="tuapassword"
python garmin_mcp_server.py --transport http --port 8000
```

Poi collega: `http://tuoserver:8000/mcp`

---

## Formato step per push_workout

```json
[
  {
    "type": "warmup",
    "duration_type": "time",
    "duration_value": 600,
    "pace_low": "7:05",
    "pace_high": "6:25",
    "hr_low": 120,
    "hr_high": 140,
    "primary": "hr"
  },
  {
    "type": "run",
    "duration_type": "distance",
    "duration_value": 5000,
    "pace_low": "6:20",
    "pace_high": "6:00",
    "hr_low": 135,
    "hr_high": 150,
    "primary": "hr"
  },
  {
    "type": "repeat",
    "repeat_count": 6,
    "steps": [
      {
        "type": "run",
        "duration_type": "time",
        "duration_value": 20,
        "pace_low": "5:00",
        "pace_high": "4:10",
        "primary": "pace"
      },
      {
        "type": "recover",
        "duration_type": "time",
        "duration_value": 40,
        "pace_low": "7:30",
        "pace_high": "6:30",
        "hr_low": 120,
        "hr_high": 145,
        "primary": "hr"
      }
    ]
  },
  {
    "type": "cooldown",
    "duration_type": "time",
    "duration_value": 300,
    "pace_low": "7:30",
    "pace_high": "6:30",
    "hr_low": 110,
    "hr_high": 140,
    "primary": "hr"
  }
]
```

### Regole target

- `primary: "hr"` → la frequenza cardiaca è il target principale sul watch, il ritmo è secondario
- `primary: "pace"` → il ritmo è il target principale, la FC è secondaria
- `primary: "none"` → nessun target (a percezione)

Questo è lo stesso formato doppio target testato e funzionante dello script `upload_workouts_venezia_v3.py`, con i `targetValueOne/Two` hoistati correttamente al livello root dello step.

---

## Esempio prompt per Claude

```
"Mostrami le ultime 10 corse con ritmo e frequenza cardiaca"

"Com'è stato il mio sonno questa settimana?"

"Crea un allenamento di tempo run per domani: 15 min riscaldamento,
 4x1km a 5:00/km con 2min recupero, 10 min defaticamento.
 FC primaria sui facili (130-147), ritmo primario sugli intervalli."

"Carica il piano allenamento del prossimo mese: martedì facile 10km,
 giovedì progressivo 12km, domenica lungo da 20km a 30km crescente."

"Quanto ho corso nelle ultime 4 settimane? Sto aumentando troppo il volume?"

"Cancella tutti i workout del piano vecchio e ricarica quelli nuovi."
```

---

## Autenticazione

Il server usa `garminconnect` che si autentica con email/password e gestisce internamente i token OAuth (via `garth`, token longevi ~1 anno). **La password non viene salvata** — solo i token di sessione sono persistiti da garth in `~/.garth/`.

Se hai MFA attivo, fai prima il login interattivo:

```bash
python -c "from garminconnect import Garmin; g = Garmin('email', 'pass'); g.login()"
```

---

## Differenze rispetto al server TypeScript

| | TypeScript (precedente) | Python (questo) |
|---|---|---|
| Libreria Garmin | garmin-connect npm (basica) | garminconnect Python (134 metodi, testata) |
| Doppio target | Non supportato | ✅ Completo (fix v3 hoisted) |
| upload_running_workout | Non disponibile | ✅ Nativo |
| schedule_workout | Wrappato in try/catch vuoto | ✅ Funzionante |
| delete_workout | Non implementato | ✅ Implementato |
| Health data | Solo steps, HR, sleep | ✅ Steps, HR, HRV, stress, sleep, body battery, SpO2, training readiness |
| Testato con dati reali | No | Sì (script v3 validato su Garmin Connect) |

---

## Disclaimer

Progetto non affiliato con Garmin. Usa `garminconnect` che si basa su endpoint reverse-engineered. Solo per uso personale.

## License

MIT
