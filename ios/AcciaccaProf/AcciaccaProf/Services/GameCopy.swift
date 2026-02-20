import Foundation

enum GameCopy {
    static var lezione1: String {
        return "Apparirà un solo robot ribelle alla volta: se lo disattivi guadagni punti, se lo lasci andare o se sbagli perdi punti."
    }

    static var lezione2: String {
        return "Appariranno 1 robot alleato e 1 robot ribelle. Disattiva il ribelle per guadagnare punti."
    }

    static var lezione3: String {
        return "Come la lezione 2, ma robot alleati/ribelli casuali e la bidella che porta circolari."
    }

    static var gameOver: String {
        return "Punteggio finale: %@. Valutazione: %@/10. Puoi ricominciare da capo premendo Start."
    }

    static var istruzioni: String {
        return """
Punteggi (moltiplicati dalla velocita'):
• +2 disattivi robot ribelle
• -1 robot ribelle sfuggito
• -2 disattivi robot alleato
• +1 robot alleato lasciato andare
• +5 disattivi l'assistente
• -1 bidella lasciata andare
• -1 colpisci un banco (zampilli)
• -1 colpo a vuoto
• +10 circolare buona
• -10 circolare cattiva

Velocita': la velocita' applica un moltiplicatore logaritmico ai punti, da 0.5x (velocita' 0) fino a 3x (velocita' 100).
Tabella moltiplicatori:
• 0% = 0.50x
• 25% = 1.78x
• 50% = 2.35x
• 75% = 2.72x
• 100% = 3.00x

Lezioni (automatiche):
1) Solo robot ribelle (10 uscite)
2) Robot ribelle + robot alleato (10 uscite)
3) Come la 2 + assistente con circolari (10 uscite)
4) Pentathlon: 5 prove speciali (Memory, Riflessi, Scambio di posto, Bersagli mobili, Sequenza)
Al termine il gioco finisce e puoi ricominciare con Start.
"""
    }

    static var note: String {
            return "Questo gioco e' stato sviluppato in Delphi nel 2007 tra i banchi di scuola del quinto liceo da Jacopo Moscioni, come svago. Era diventato un po' popolare tra i frequentatori del forum del liceo del tempo. 19 anni dopo, nel 2026, rinasce sottoforma di app per iOS, nella versione Reloaded e con l'invasione dei robot. Il gameplay è rimasto identico e semplice come al tempo"
    }

    static var retryPentathlon: String {
        return "Hai sbagliato. La prova riparte da capo."
    }

    static var circolareIntro: String {
        return "E' entrata la bidella con una circolare. Scegline una e clicca su ok. Se sei fortunato, la comunicazione sara' buona e guadagnerai punti, altrimenti ne perderai."
    }

    static func pentathlonRule(for mode: Int) -> String {
        switch mode {
        case 1:
            return "Memory: per 0.5s vedi 4 robot (2 alleati, 2 ribelli). Poi si coprono. Abbina le coppie. +2 corretto, -1 errore.\n\nTocca Coach Perla per rivedere la regola."
        case 2:
            return "Riflessi: compaiono 3 robot ribelli e 3 alleati a comparsa. Disattiva solo i ribelli: quando li prendi spariscono per sempre. Se disattivi un alleato, il minigioco riparte.\n\nTocca Coach Perla per rivedere la regola."
        case 3:
            return "Scambio di posto: appaiono 3 alleati, 3 ribelli, la bidella e Coach Perla sui banchi laterali. Poi si coprono. Al centro appare uno alla volta: tocca il banco dove era seduto. Se sbagli, si riparte. Tocca Coach Perla per rivedere la regola."
        case 4:
            return "Rischio controllato: 3 robot ribelli e 3 alleati sui banchi. Disattiva SOLO i ribelli che hanno un alleato vicino (su/giu/sx/dx). Se disattivi un alleato o un ribelle senza alleato vicino, il minigioco riparte.\n\nTocca Coach Perla per rivedere la regola."
        case 5:
            return "Sequenza: i robot appaiono in ordine. Ripeti toccando i banchi nella stessa sequenza. Errore = -2 e si riparte.\n\nTocca Coach Perla per rivedere la regola."
        default:
            return ""
        }
    }

    static var privateAlertEnabled: String {
        return "Modalità VA attivata."
    }

    static var privateAlertDisabled: String {
        return "Modalità VA disattivata."
    }

    static var onboardingPage1Title: String {
        return "Acciacca Prof"
    }
    static var onboardingPage1Subtitle: String {
        return "2007: niente app, solo PC"
    }
    static var onboardingPage1Body: String {
        return "Nel 2007 non esistevano ancora le app. Gli smartphone moderni stavano per arrivare, e pure l’App Store sarebbe nato solo pochi mesi dopo. E mentre i suoi compagni di classe studiavano e facevano i compiti, Jacopo da Perugia, invece di fare i compiti, programmava per divertimento. In quell’epoca smanettava su Windows e realizzava piccoli giochi per il gusto di farli. Non si chiamavano app. Si chiamavano \"programmini\"."
    }

    static var onboardingPage2Title: String {
        return "Dal PC al forum"
    }
    static var onboardingPage2Subtitle: String {
        return "Windows XP, Delphi e ricreazioni"
    }
    static var onboardingPage2Body: String {
        return "E' così che nacque l'Acciacca Prof, scritto originariamente in Delphi per Windows, in piena era XP. Un giochino semplice, simpatico, con spirito goliardico: quello delle ricreazioni, dei banchi di scuola e delle risate tra compagni. Finì sul forum scolastico, e gli studenti lo usavano personalizzandolo con le facce dei propri prof, divertendosi a schiacciarli! Diventò un piccolo meme, prima dei meme. Il 25 febbraio 2007 un commento recitò: “Io volevo la perla e il pentathlon”."
    }

    static var onboardingPage3Title: String {
        return "2026: ritorno"
    }
    static var onboardingPage3Subtitle: String {
        return "Invasione robot, pentathlon e coach Perla"
    }
    static var onboardingPage3Body: String {
        return "Chi è Perla? Perla era la prof di educazione fisica del liceo. La richiesta rimase lì, sospesa, inascoltata. Per anni. Lustri. Nel 2026 Acciacca Prof è tornato in vita su dispositivi Apple in versione reloaded: la stessa modalità di gioco e la stessa banale semplicità. Ma con delle novità: I robot futuristici hanno invaso la scuola, ed è il tuo compito sconfiggerli per ripristinare l'ordine in aula! La coach Perla ti aiuterà nella gara del pentathlon, ma sarai tu che avrai la responsbilità di salvare la tua classe! Un piccolo gioco nato per scherzo, tornato in vita dopo 19 anni con dentro la stessa anima… Jacopo da Perugia, colpisce ancora!"
    }

    static var onboardingPage4Title: String {
        return "Come si gioca"
    }
    static var onboardingPage4Subtitle: String {
        return "Spiegazione tecnica"
    }
    static var onboardingPage4Body: String {
        return "La dinamica di gioco è molto semplice: Si basa sul gioco di \"Schiaccia la talpa\", solo che al posto della talpa, appariranno dei robot tra i banchi. Ma attenzione! non tutti i robot sono cattivi! Ci sono anche quelli buoni. Se colpisci quelli buoni perdi punti e avrai un brutto voto!"
}

    static var onboardingPage5Title: String {
        return "La bidella"
    }
    static var onboardingPage5Subtitle: String {
        return "Cosa fa la bidella?"
    }
    static var onboardingPage5Body: String {
        return "La bidella è un personaggio neutro del gioco. A volte può bussare ed entrare in classe per portare una circolare. La devi bloccare, così potrai leggere la circolare. Ma ATTENZIONE: non tutte le circolari sono belle! La sorte ti assisterà?! Buona partita!"
    }

    static var settingsIntro: String {
        return "Qui puoi usare le foto dalla tua galleria da inserire nel gioco e renderlo unico."
    }

    static var settingsUnlockDescription: String {
        return "Sblocchi la possibilità di personalizzare le facce dei robot alleati, dei ribelli, della bidella e della Coach Perla al Pentathlon."
    }
}
