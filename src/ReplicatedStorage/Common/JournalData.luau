local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ZombieTextColors = require(ReplicatedStorage.Common.ZombieTextColors)

local JournalData = {}

JournalData.zombieTypes = {
    ["Swarmer"] = {
        layoutOrder = 1,
        titleColor = ZombieTextColors.Swarmer,
        description = "The most common zombie type. They're weak and easy to kill. However, when Swarmers are in a group, they can be quite dangerous. "
            .. "The best way to handle them is to shoot them in the head or use a high fire-rate weapon. "
    },
    ["Crawler"] = {
        layoutOrder = 2,
        titleColor = ZombieTextColors.Crawler,
        description = "Crawlers can dive you when they're close enough. Their attacks can distract you while other zombies get close. "
            .. "They should be killed as soon as possible before they can dive onto you. ",
    },
    ["Stalker"] = {
        layoutOrder = 3,
        titleColor = ZombieTextColors.Stalker,
        description = "Almost invisible, they're hard to notice unless you have night vision. Although they're slow, their attacks hurt a lot. ",
    },
    ["Hopper"] = {
        layoutOrder = 4,
        titleColor = ZombieTextColors.Hopper,
        description = "Hoppers can jump very high, so they can jump over your walls. They're one of the weakest zombie types, but their small proportions are hard to hit. ",
    },
    ["Spitter"] = {
        layoutOrder = 5,
        titleColor = ZombieTextColors.Spitter,
        description = "The only zombie type that can attack you from a distance. Their acid spit splashes and can burn you. "
            .. "The acid causes a lot of damage to your body and your defenses. The best way to stop them is to dodge their spit and shoot. ",
    },
    ["Predator"] = {
        layoutOrder = 6,
        titleColor = ZombieTextColors.Predator,
        description = "Predators are one of the most dangerous zombie types. They're fast, hurt a lot, and can take a lot of hits. "
            .. "They must be killed as soon as possible. ",
    },
    ["Abomination"] = {
        layoutOrder = 7,
        titleColor = ZombieTextColors.Abomination,
        description = "Tanky zombies that will explode when they die. Their explosion will hurt anything nearby, even their own kind. "
            .. "Abominations should be killed as far away from you as possible. ",
    }
}

JournalData.survival = {
    ["Food"] = {
        layoutOrder = 1,
        description = "Food can be obtained by hunting deer, picking berries, or by finding them in boxes. "
            .. "Raw meat must be cooked at a campfire to be safe to eat. "
            .. "Food can restore your health, depending on how much effort you put into cooking it. ",
    },
    ["Water"] = {
        layoutOrder = 2,
        description = "Water can be gathered from lakes or ponds. Use an empty bottle to collect the water. "
            .. "However, water must be safe to drink. Boil water at a campfire to purify it. "
            .. "You can build a rain barrel to collect rain water, which doesn't need to be purified. ",
    },
    ["Shelter"] = {
        layoutOrder = 3,
        description = "You can either find a shelter or build one using a build shovel. "
            .. "Shelters provide protection from the elements and zombies. "
            .. "They also provide a place to store your resources and a place to sleep. ",
    },
    ["Build Shovel"] = {
        layoutOrder = 4,
        description = "The build shovel is used to build shelters and other structures. "
            .. "It can also be used to break down walls and other structures. "
            .. "Build shovels are vital to upgrading your base and equipment, so it's important to make one as soon as possible. ",
    },
    ["Equipment"] = {
        layoutOrder = 5,
        description = "You can upgrade your equipment by using a workbench. "
            .. "The workbench can be used to upgrade your weapons, armor, and other equipment. ",
    },
    ["SATCOM Radio"] = {
        layoutOrder = 6,
        description = "The SATCOM radio is used to set your spawn location. "
            .. "Once you've built a base or shelter, you can place one down to spawn there after death. ",
    }
}

return JournalData