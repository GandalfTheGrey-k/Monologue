--[[
    Monologue Data Module: Party Banter
    PURE DATA TABLE.

    When a party member who also runs Monologue says one of their lines aloud, one other
    Monologue user nearby may answer them now and then (Voice Lines tab, "Party banter").
    {target} is the party member who just spoke.

      Kill      they just said something after a kill
      Idle      idle chatter
      EatDrink  they sat down to eat or drink
      Rest      they walked into an inn or a city
      Mount     they mounted up
      Loot      they said something about their loot
      Level     they just levelled up (no line of theirs needed)

    Further down: GreetBack, Close (the first speaker's last word), Thanks / ThanksReply (after
    a resurrection), Friend and Cool (answers shaped by who they are to you), SameClass, and
    Data.DuelTalk (before and after a duel).

    Shared by every race and class: keep them faction- and class-neutral.
    Follow VOICE_GUIDE.md: specific, in-world, calm.
--]]

MonologueEngine.Data.BanterLines = {
    Kill = {
        "Nicely done, {target}.",
        "Not bad, {target}. Not bad at all.",
        "I had it, {target}. But fine.",
        "Good work, {target}. Next one's mine.",
        "{target}, you missed a bit. Oh, no, it's dead.",
        "Show-off, {target}.",
        "I'll write that one down, {target}.",
        "That's one for you, {target}. I'm still ahead.",
    },
    Idle = {
        "You say that every time, {target}.",
        "Hm. Fair point, {target}.",
        "{target}, you think too much.",
        "Can't argue with that, {target}.",
        "I was just thinking the same, {target}.",
        "Tell me about it, {target}.",
        "Aye. Well said, {target}.",
        "If you say so, {target}.",
    },
    EatDrink = {
        "Save me some, {target}.",
        "That smells better than mine, {target}.",
        "Don't eat it all, {target}.",
        "{target}, you're always eating.",
        "Good idea, {target}. I'll join you.",
        "Pass it here when you're done, {target}.",
        "Eat up, {target}. Long road yet.",
        "Is that cheese, {target}? Share.",
    },
    Rest = {
        "First round's on you, {target}.",
        "Finally, {target}. My feet were done an hour ago.",
        "Grab us a table, {target}.",
        "I'll take the seat by the fire, {target}.",
        "Don't get comfortable, {target}. We leave at dawn.",
        "Ah, {target}. Somewhere with walls.",
        "Find the innkeeper, {target}. I'll find the stew.",
        "Rest well, {target}. You've earned it.",
    },
    Mount = {
        "Lead the way, {target}.",
        "Right behind you, {target}.",
        "Race you, {target}.",
        "Don't leave me in the dust, {target}.",
        "Slow down, {target}. Some of us have short legs.",
        "Where to, {target}?",
        "After you, {target}.",
        "Try to keep up, {target}.",
    },
}

-- Talking with other Monologue users (see "Talking with other Monologue users" in
-- Monologue_Core.lua). {target} is the other player, by their Total RP name when they have one.
local B = MonologueEngine.Data.BanterLines

-- Another Monologue user greeted you aloud; half the time your usual greeting for them is
-- used instead
B.GreetBack = {
    "Hello to you too, {target}.",
    "Well met yourself, {target}.",
    "{target}! Good to see you too.",
    "Same to you, {target}. Keeping well?",
    "Hello yourself, {target}.",
    "Ah, there you are, {target}.",
    "Glad you stopped, {target}.",
    "And a good day to you, {target}.",
    "Likewise, {target}. Likewise.",
    "You beat me to it, {target}. Hello.",
}

-- Someone answered a party member's level-up or loot line
B.Level = {
    "Well done, {target}. You've earned that one.",
    "Look at you, {target}. Moving up.",
    "Congratulations, {target}.",
    "Another notch on the belt, {target}.",
    "Drinks on you tonight, {target}.",
    "About time, {target}.",
    "You'll be teaching me soon, {target}.",
    "That's the spirit, {target}. Keep going.",
}
B.Loot = {
    "Anything good, {target}?",
    "Lucky, {target}.",
    "Don't spend it all at once, {target}.",
    "Is that mine? It looks like mine.",
    "Share the wealth, {target}.",
    "Better you than the vendor.",
    "I saw that first, {target}.",
    "Good find.",
}

-- The first speaker's last word, after someone answered them (Any: for topics without their own)
B.Close = {
    Kill = {
        "Told you it was easy.",
        "We make a decent team, {target}.",
        "Next one's yours, then.",
        "I'll count that one as half mine.",
        "Don't let it go to your head.",
        "Easy, wasn't it?",
        "Good teamwork, that.",
        "Right. Who's next?",
    },
    Idle = {
        "Glad someone agrees.",
        "I'll take that as a yes.",
        "Hm. Maybe.",
        "You're not wrong.",
        "Now you're thinking.",
        "Exactly my point.",
        "See? I'm not mad.",
        "Good. Glad that's settled.",
    },
    EatDrink = {
        "Get your own, {target}.",
        "Fine. Half.",
        "Not a crumb, {target}.",
        "Mm. Worth the wait.",
        "There's more in my pack. Probably.",
        "Hands off my crust, {target}.",
        "I'll trade you for an apple.",
        "You'd have to fight me for it.",
    },
    Rest = {
        "Deal. Your round after.",
        "I'll hold you to that, {target}.",
        "Wake me at dawn.",
        "Best idea all day.",
        "Bed first, stories later.",
        "And a bath. Light, a bath.",
        "Fine, but you're paying.",
        "Make it two bowls of stew.",
    },
    Mount = {
        "Keep up, then.",
        "Eat my dust, {target}.",
        "No promises.",
        "Last one there buys supper.",
        "Hold on to something.",
        "See you there, slowpoke.",
        "Mind the low branches.",
        "Don't fall off this time.",
    },
    Loot = {
        "Saw it, grabbed it, {target}.",
        "Mine. Fair and square.",
        "You can have the next one.",
        "Don't look at me like that.",
        "It'll look better on me.",
        "Fair's fair. You'd have done the same.",
        "Next drop's yours. Promise.",
        "I'll split the coin later.",
    },
    Level = {
        "Thanks. Feels good.",
        "Still the same old me.",
        "Drinks on me, then.",
        "Took long enough, didn't it?",
        "Thanks, {target}. Onward.",
        "Feels good to say it.",
        "Couldn't have done it alone.",
        "Now the real work starts.",
    },
    Any = {
        "Ha. Fair enough.",
        "We'll call it a draw, {target}.",
        "Mm.",
        "Fair point, well made.",
        "We'll see.",
        "Right you are.",
        "Fair.",
        "Perhaps.",
    },
}

-- A player raised you (you thank them), and their answer if they run Monologue
B.Thanks = {
    "Thanks, {target}. I owe you one.",
    "Back on my feet. Thank you, {target}.",
    "I owe you, {target}.",
    "That was a long walk I didn't have to make. Thanks.",
    "Thank you, {target}. Let's not do that again.",
    "Much obliged, {target}.",
    "Still breathing, thanks to you, {target}.",
    "You're a lifesaver, {target}. Truly.",
}
B.ThanksReply = {
    "Try not to make a habit of it, {target}.",
    "Anytime, {target}. Well. Most times.",
    "Stay alive this time, {target}.",
    "That's one you owe me.",
    "Back on your feet, {target}. Good.",
    "Mind your footing next time.",
    "You'd do the same for me.",
    "Welcome back, {target}.",
}

-- Answers to someone you marked as a friend (/mono friend)
B.Friend = {
    Greet = {
        "There's my favorite face, {target}.",
        "Always good to see you, {target}.",
        "I was hoping you'd turn up, {target}.",
        "My friend. How've you been, {target}?",
        "Come here, you. Good to see you, {target}.",
        "You're a welcome sight, {target}.",
        "There you are, old friend.",
        "Hello, {target}. I saved you a seat.",
    },
    Kill = {
        "Couldn't have done it better, {target}.",
        "Knew I could count on you, {target}.",
        "Like old times, {target}.",
        "You've still got it, {target}.",
        "Proud of you, {target}. Don't tell anyone.",
        "That's my friend. Good work.",
        "Together again. Works every time.",
        "Beautiful work, {target}.",
    },
    Idle = {
        "You always know what to say, {target}.",
        "Ha. That's why I keep you around, {target}.",
        "True, old friend.",
        "I've missed this, {target}.",
        "Well said, as always.",
        "You've always had a way with words, {target}.",
        "Ha. Spoken like a true friend.",
        "I'll remember that one, {target}.",
    },
    EatDrink = {
        "Pull up a seat, {target}. I'll join you.",
        "Pass me some, old friend.",
        "Supper with friends. Best part of the day.",
        "Save me the good bit, {target}.",
        "Just like the old days, eh?",
        "Share and share alike, {target}.",
        "Here, take the bigger half.",
        "Eat up, old friend. You've earned it.",
    },
    Rest = {
        "First round's mine, {target}.",
        "Sit with me, {target}.",
        "A warm fire and a good friend.",
        "We've earned this one, {target}.",
        "Let's not move for an hour.",
        "Nowhere I'd rather be, {target}.",
        "Long day. Good company, though.",
        "Wake me if anything happens, {target}.",
    },
    Mount = {
        "Ride with me, {target}.",
        "Side by side, then.",
        "I'll follow you anywhere, {target}. Within reason.",
        "Lead on, old friend.",
        "Same road, same company. Good.",
        "After you, old friend.",
        "Right with you, {target}.",
        "Wherever you're going, I'm coming.",
    },
    Loot = {
        "Good for you, {target}. Really.",
        "You deserve it, old friend.",
        "Ha. Lucky as ever, {target}.",
        "Wear it well, {target}.",
        "That's going straight to your head, isn't it?",
        "Couldn't have happened to a better friend.",
        "Look at you, {target}. Treasure suits you.",
        "Keep it. You'd give it to me anyway.",
    },
    Level = {
        "So proud of you, {target}.",
        "Look how far you've come, {target}.",
        "I remember when you couldn't hold a sword, {target}.",
        "Well earned, old friend.",
        "Drinks are on me tonight, {target}.",
        "You've worked hard for this, {target}.",
        "Every bit of it earned, old friend.",
        "Look at you go, {target}.",
    },
}

-- Answers to someone of a race you've set a wary, gruff or disdainful stance toward
B.Cool = {
    Greet = {
        "Oh. {target}.",
        "Back again, {target}?",
        "Mm. Hello.",
        "Fine. Hello, {target}.",
        "I noticed you, {target}.",
        "Hm. You're here.",
        "If you must, {target}.",
        "Ah. It's you.",
    },
    Kill = {
        "Hmph. Not bad.",
        "Adequate, {target}.",
        "I suppose that'll do.",
        "Lucky swing, {target}.",
        "I could have done that.",
        "Hm. Passable.",
        "Could've been quicker.",
        "I've seen worse, {target}.",
    },
    Idle = {
        "Noted.",
        "Hm.",
        "Your opinion's noted, {target}.",
        "Is that so.",
        "I'll think about it. No.",
        "Mm-hm.",
        "Fascinating. No.",
        "Keep talking. I'm not listening.",
    },
    EatDrink = {
        "Eat quietly, {target}.",
        "Your food smells odd.",
        "Keep it on your side.",
        "Mm. Enjoy, I suppose.",
        "Don't drop crumbs on me.",
        "Chew with your mouth shut, {target}.",
        "Don't offer me any.",
        "That smells like old boots.",
    },
    Rest = {
        "Sit over there, {target}.",
        "I'll take my own table.",
        "Don't snore, {target}.",
        "Fine. Rest.",
        "I'm buying my own drink.",
        "Don't sit too close.",
        "I'll be at the bar. Alone.",
        "Sleep lightly, {target}.",
    },
    Mount = {
        "Go on, then.",
        "Don't wait for me, {target}.",
        "I know the way, thanks.",
        "Ride ahead. Far ahead.",
        "Mind your dust, {target}.",
        "Try not to fall off.",
        "Lead, then. I'll follow at a distance.",
        "Don't kick dust at me, {target}.",
    },
    Loot = {
        "Hmph. Keep it.",
        "Lucky, I suppose.",
        "I didn't want it anyway.",
        "Enjoy it, {target}. While it lasts.",
        "Typical.",
        "Lucky again.",
        "Of course it went to you.",
        "Hm. It'll break soon.",
    },
    Level = {
        "Hm. Congratulations, I suppose.",
        "Took you long enough.",
        "Try not to gloat, {target}.",
        "Fine. Well done.",
        "Still behind me, {target}.",
        "Mm. Finally.",
        "About time, I suppose.",
        "Don't expect a party, {target}.",
    },
}

-- After a kill, to someone of your own class
B.SameClass = {
    "I'd have done it the same way, {target}.",
    "Good form, {target}. I taught you that.",
    "Showing off our trade, {target}?",
    "Not bad. For one of us.",
    "Our trainer would be proud, {target}.",
    "I saw that trick. I'm stealing it.",
    "Same trade, better timing. Mine, I mean.",
    "Clean work. Ours always is.",
}

-- Duels. Challenge: you challenged someone. Accept: someone challenged you (dropped if the
-- duel never starts). WinReply: you won against another Monologue user, and answer after
-- they've conceded.
MonologueEngine.Data.DuelTalk = {
    Challenge = {
        "Fancy a bout, {target}?",
        "Show me how you've been training, {target}.",
        "Friendly, mind. Mostly.",
        "First to fall buys the drinks.",
        "Loser carries the bags, {target}.",
        "No hard feelings after, {target}.",
        "Whenever you're ready, {target}.",
        "Just a little practice.",
    },
    Accept = {
        "You're on, {target}.",
        "Alright. Don't sulk after.",
        "Gladly, {target}.",
        "I was hoping you'd ask.",
        "Fine. Best of one.",
        "Let's go, then.",
        "Show me your best, {target}.",
        "Careful what you wish for, {target}.",
    },
    WinReply = {
        "Good fight, {target}. Closer than it looked.",
        "You had me worried for a moment, {target}.",
        "Hand up. You fought well.",
        "Next time's yours, maybe.",
        "Well fought. Drinks are on you.",
        "Don't feel bad. I've had practice.",
        "Again tomorrow, {target}?",
        "That was fun. Thanks, {target}.",
    },
}
