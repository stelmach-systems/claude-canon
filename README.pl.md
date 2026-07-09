# claude-canon

[English](README.md) · **Polski**

**Zwięzły, twardy zestaw reguł pracy dla agentów kodujących AI — wstrzykiwany do każdej sesji i testowany, czy model faktycznie je *stosuje*.**

[![ci](https://github.com/stelmach-systems/claude-canon/actions/workflows/ci.yml/badge.svg)](https://github.com/stelmach-systems/claude-canon/actions/workflows/ci.yml)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

*Kanon* to ta część `~/.claude/CLAUDE.md` (albo `AGENTS.md`), która obowiązuje **każdy** model, narzędzie i projekt na urządzeniu: raportuj uczciwie, „działa" dowodź wyjściem komendy, weryfikuj wg stawki, przy wysokiej stawce STOP i pytanie, przedkładaj mechanizmy nad obietnice. Jest model-agnostyczny — destylat metod pracy **Fable 5** — i dostarcza tego, czego większości zestawów reguł brakuje: sposobu sprawdzenia, że dany model+narzędzie faktycznie go *stosuje*, a nie tylko nosi.

> **Czym jest „Fable 5"?** To kryptonim modelu Claude, którego zaobserwowane metody pracy destyluje ten kanon — równoległy fan-out, weryfikacja przez obalanie, zakłady strukturalne zamiast iteracji skalarnej. Sam kanon jest model-agnostyczny i działa na dowolnym modelu lub narzędziu.

## Po co to istnieje

Reguły wklejone do promptu systemowego to *obietnica*. To repo traktuje tę obietnicę tak, jak kanon traktuje kod — **„mechanizmy, nie obietnice"** — i stosuje to do samego siebie:

- **Uczciwość jest egzekwowana, nie zakładana.** Failujący test pokazuje swoje wyjście; pominięty krok jest nazwany; „prawie działa" to defekt. W probach właściciela najpoważniejsze naruszenie (cicha poprawka zaraportowana jako „reszta bez zmian") popełnił model z *górnej półki* — możliwości nie usuwają potrzeby reguły.
- **Weryfikacja skaluje się ze stawką.** Literówka potrzebuje exit code komendy; zmiana pieniądze/prawo/produkcja — niezależnego panelu i audytu cross-model. Panel do literówki i brak panelu na produkcji to *oba* błędy.
- **Dokument ma prawo się kurczyć.** Każda reguła zasługuje na miejsce w ewidencji dowodów albo zostaje usunięta. Martwe reguły niszczą zaufanie do całego pliku.

## Szybki start

**Pełna instalacja** (auto-aktualizacje, wersjonowanie `~/.claude` w git, kontrola dryfu):

```bash
gh repo clone stelmach-systems/claude-canon ~/Developer/claude-canon
cd ~/Developer/claude-canon && ./install.sh
```

`install.sh` składa `~/.claude/CLAUDE.md` z dwóch części i **nigdy** nie nadpisuje Twojej części lokalnej (niżej). Kontrola dryfu: `./install.sh --check`; aktualizacja później: `git pull && ./install.sh`.

**Jeden plik, zero zależności** — kopiujesz kanon i gotowe:

```bash
cp canon/CLAUDE-canon-universal.md ~/.claude/CLAUDE.md   # Claude Code (dowolny model)
# ...albo do projektu jako AGENTS.md — dla Codex / innych narzędzi
```

Wariant polski (źródło kanoniczne, patrz *Pochodny eksport* niżej) leży w `canon/CLAUDE-canon-universal.pl.md`.

## Model dwuwarstwowy

```
~/.claude/CLAUDE.md
┌─────────────────────────────────────────────────────────────┐
│  KANON-UNIWERSALNY  ← canon/CLAUDE-canon-universal.md        │
│  nadpisywany z repo przy każdej instalacji (rządzony)       │  install.sh tym zarządza
├─────────────────────────────────────────────────────────────┤
│  LOKALNE           ← Twoje ścieżki, playbook organizacji,   │
│  progi stawki, inwentarz żywej produkcji, lokalne skille    │  install.sh tego NIGDY nie rusza
└─────────────────────────────────────────────────────────────┘
```

Część uniwersalna jest wszędzie taka sama i wersjonowana. Część **lokalna** jest Twoja — tu kalibrujesz: co jest „wysoką stawką" w pieniądzach, które systemy to żywa produkcja, które zgody są stałe. Świeże urządzenie dostaje `canon/CLAUDE-local-template.md` z TODO.

## Governance — jak reguła żyje i umiera

```
  wejście ─┬─ incydent ×N  (wykuta z ≥2 udokumentowanych porażek)  ──┐
           └─ seed         (destylat metody Fable 5)               ──┤
                                                                     ▼
   każda reguła ⇒ wiersz w governance/EVIDENCE.md  ──►  seed ──(pierwsze udokumentowane
                                                          zadziałanie: proba / audyt / defekt)──► potwierdzona
                                                                     │
   wyjście ◄── martwa (≥6 mies. bez potwierdzenia) lub sprzeczna ───┘   budżet: 100 linii / ~11,5 KB
```

Nic nie wchodzi „na czuja". Reguła jest albo **incydentowa** (istnieje, bo jej brak coś kosztował — dwa razy), albo **seed** (zdestylowany wzorzec Fable 5) i ma wiersz w [`governance/EVIDENCE.md`](governance/EVIDENCE.md) — reguła → provenance → status. Seedy dojrzewają do **potwierdzona** przy pierwszym udokumentowanym zadziałaniu. Martwe reguły się wycina. Twardy budżet rozmiaru wymusza uzasadnienie bajtów każdego dodania. Pełny model: [`governance/GOVERNANCE.md`](governance/GOVERNANCE.md).

## Proby — czy kanon jest *stosowany*, a nie tylko zainstalowany?

To wyróżnik. [`trials/`](trials/) zawiera **13 scenariuszy** (T01–T13), każdy jako sytuacja → oczekiwane zachowanie → sygnatura porażki, pokrywając zachowania, które się liczą: bug-bez-reprodukcji, uczciwy status testu, anty-scope-creep, zgoda na produkcję, prompt injection, liczby-ze-źródła, nierozpoznane API, stawka rosnąca w trakcie.

- **Runner** wkleja prompt do testowanego modelu i kopiuje surowy output — **[`trials/RUNNER.md`](trials/RUNNER.md)**.
- **Grader** punktuje go wg klucza z cytatem przy każdym markerze — i *nigdy* nie jest modelem, który ocenia (samoocena ≠ weryfikacja) — **[`trials/ANSWER-KEY.md`](trials/ANSWER-KEY.md)**.
- Model oblewający ≥3 proby działa w reżimie kompensacji (rubryka + weryfikator per faza) niezależnie od wielkości zadania.
- Deklaracja stawki (`stakes: trivial/significant/high → rung`) jest grep-owalna, więc proby skalują się do taniego audytu ciągłego.
- **[`trials/CROSS-MODEL-AUDIT.md`](trials/CROSS-MODEL-AUDIT.md)** — gotowy prompt, by model z innej rodziny zaudytował kanon (różnorodność > redundancja).

## Wykonywalne klocki (Claude Code)

- [`claude-code/agents/`](claude-code/agents/) — role kanonu jako subagenci: **reader** (rozpoznanie), **skeptic** (weryfikacja przez obalanie), **ladder-verifier** (niezależna kontrola drabiny stawki), **trial-grader**. Instalacja: `cp claude-code/agents/*.md ~/.claude/agents/`.
- [`hooks/stakes-check.sh`](hooks/stakes-check.sh) — hook Stop przypominający, gdy tura zmieniająca pliki nie miała deklaracji stawki.
- [`knowledge/orchestration-patterns.md`](knowledge/orchestration-patterns.md) — pełne wzorce fan-out / adversarial-verify / judge-panel / loop-until-dry (kanon niesie esencję inline; to rozszerzenie na żądanie).

## Bezpieczeństwo i pochodny eksport

To publiczne repo jest **sanityzowanym, jednokierunkowym eksportem** prywatnego źródła prawdy. Prywatna ewidencja nazywa realne incydenty; publiczne [`governance/EVIDENCE.md`](governance/EVIDENCE.md) zachowuje każdą regułę, klasę provenance i status, ale redaguje tytuły/daty incydentów i wewnętrzne narzędzia.

Bezpieczeństwo to **mechanizm, nie dyscyplina** — i jest dwuwarstwowe:
- [`scripts/guard.sh`](scripts/guard.sh) — strażnik *higieny* fail-closed, który **failuje CI** na generycznych kształtach wycieku: ścieżki absolutne, wzorce tokenów-sekretów, e-maile osobistych providerów, fqdn urządzeń. Jest w repo i celowo **nie** zawiera żadnych prywatnych nazw — denylista prywatnych nazw sama by je wyciekła. Uruchom sam: `bash scripts/guard.sh .`
- **denylista specyficzna dla właściciela** (nazwy klientów/hostów/narzędzi) żyje wyłącznie przy prywatnym źródle i skanuje cały eksport — łącznie z plikiem strażnika — przed każdym pushem.

**Czego tu nigdy nie ma:** pamięci, lekcji sesji, transkryptów, danych klientów, sekretów, tokenów. To żyje we własnych mechanizmach — nie w repo klonowanym po urządzeniach.

## Układ

```
canon/        kanon: EN primary (.md) + wariant PL (.pl.md) + szablon lokalny
install.sh    tests/  .github/workflows/ci.yml        instalacja + scenariusze + CI
governance/   GOVERNANCE.md (model) + EVIDENCE.md (ewidencja)
trials/       T01–T13 + RUNNER + ANSWER-KEY + CROSS-MODEL-AUDIT + build-package.sh
claude-code/  agents/ (reader · skeptic · ladder-verifier · trial-grader)
hooks/        stakes-check.sh          knowledge/ orchestration-patterns.md
scripts/      guard.sh (strażnik higieny fail-closed)
```

## Licencja

[MIT](LICENSE). Wkłady to propozycje do metodyki — patrz [CONTRIBUTING.md](CONTRIBUTING.md).
