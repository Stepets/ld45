return {
    coins = function(hero)
        hero.status["Froggy"] = (hero.status["Froggy"] or 0) + 2
    end,
    alco = function(hero)
        hero.status["Fire proof"] = (hero.status["Fire proof"] or 0) + 10
    end,
    bottle = function(hero)
        hero.status["Icarus"] = (hero.status["Icarus"] or 0) + 5
    end,
    shroom = function(hero)
        hero.status["Icarus"] = (hero.status["Icarus"] or 0) + 5
    end,
    Shroobrew = function(hero)
        hero.status["Froggy"] = (hero.status["Froggy"] or 0) + 20
        hero.status["Fire proof"] = (hero.status["Fire proof"] or 0) + 35
        hero.status["Icarus"] = (hero.status["Icarus"] or 0) + 3
    end,
}
