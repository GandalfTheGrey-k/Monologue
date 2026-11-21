--[[
    Monologue Data Module: Score-aware rivalry, duel banter and party nemesis warnings
    PURE DATA TABLE. Uses the existing rival ledger (kills, deaths, lastZone) and duel records
    (wins, losses, lastZone); nothing new to set up.

    RivalScore = { Ahead, Behind, Tied }    an enemy player you have a record with
        Ahead = you've killed them more often than they've killed you. Mixed into the PvP
        target lines and rival call-outs. Tokens: {target}, {lastzone}, {kills}, {deaths}.
    DuelBanter = { Ahead, Behind, Tied }    a marked friend you have duelled
        Mixed into friendly greetings. Tokens: {target}, {lastzone}, {wins}, {losses}.
    NemesisSpot   a warning when you spot a sworn enemy while grouped. {target} = the enemy.
    NemesisBackup a party member's answer to that warning. {target} = the party member who
                  spotted them, {rival} = the enemy.

    A line using {lastzone} is skipped while no zone is recorded for that player yet.
--]]

local Data = MonologueEngine.Data

Data.RivalScore = {
    Ahead = {
        "Back again, {target}? Didn't the lesson in {lastzone} stick?",
        "{kills} to {deaths}, {target}. You know how this goes.",
        "You again. Bring friends this time.",
        "I've put you down before. I'll do it again.",
        "Still trying, {target}? Admirable. Pointless.",
        "Last time in {lastzone} wasn't enough?",
        "You keep coming back. I keep winning.",
        "Same ending as always, {target}.",
    },
    Behind = {
        "I still owe you for {lastzone}, {target}.",
        "{deaths} times you've put me down. Not today.",
        "I remember every one of those, {target}.",
        "You've had your luck. It's run out.",
        "Careful, {target}. I've been practicing.",
        "{lastzone} was yours. This one's mine.",
        "Not again. Not to you.",
        "I've been looking for you, {target}.",
    },
    Tied = {
        "Even tally so far, {target}. Let's break the tie.",
        "{kills} each. Someone has to pull ahead.",
        "Last time in {lastzone} was close. This won't be.",
        "We're square, {target}. Not for long.",
        "One of us wins this round. It's me.",
        "Even score. I hate even scores.",
        "Tiebreaker, {target}. Ready?",
        "Back and forth, every time. Let's end it.",
    },
}

Data.DuelBanter = {
    Ahead = {
        "{target}! Come to lose another duel?",
        "{wins} to {losses}, {target}. Want to make it worse?",
        "Still sore from {lastzone}?",
        "Rematch? I'll go easy. Maybe.",
        "My favourite sparring partner. And loser.",
        "Practicing, {target}? You'll need it.",
    },
    Behind = {
        "{target}. I've been training. Just saying.",
        "You've beaten me {losses} times. That changes soon.",
        "I still feel {lastzone} in my shoulder.",
        "One day I'll win one of those duels, {target}.",
        "Don't look so smug, {target}.",
        "Rematch soon? I've got a new trick.",
    },
    Tied = {
        "{target}! We're even. Fancy a tiebreaker?",
        "{wins} each. Somebody has to win the next one.",
        "Even, {target}. I don't like even.",
        "Last duel in {lastzone} was a good one.",
        "Name the place. Let's settle it.",
        "Our duel record's a coin flip, {target}.",
    },
}

Data.NemesisSpot = {
    "Keep your guard up. {target} owes me blood from {lastzone}.",
    "Heads up. That's {target}. We have history.",
    "Watch {target}. Dangerous. Trust me.",
    "{target} is here. Stay close.",
    "That one's mine. {target}.",
    "Careful. {target} doesn't fight fair.",
}

Data.NemesisBackup = {
    "I've got your back, {target}. Point me at {rival}.",
    "Your fight is my fight, {target}.",
    "{rival}? Let's see how they like two of us.",
    "Right behind you, {target}.",
    "Say the word, {target}. I'm with you.",
    "Any enemy of yours, {target}.",
}
