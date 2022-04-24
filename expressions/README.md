= String Templates =
terraform console
"Hello ${var.hello}!" 
"Hello %{if var.hello == "world"}Mars%{else}World%{endif}"

= For Expression =

worlds=[
    "Aether",
    "Primal",
    "Crystal",
    "Chaos",
    "Light",
    "Materia",
    "Elemental",
    "Gaia",
    "Mana"
]

terraform console
[for world in var.worlds : upper(world)]

worlds_instance={
    "Aether" : "Cactuar",
    "Primal" : "Famfrit",
    "Crystal": "Diabolos",
    "Chaos" : "Cerberus",
    "Light" : "Lich",
    "Materia" : "Sephirot",
    "Elemental" : "Tonberry",
    "Gaia" : "Ultima",
    "Mana" : "Ixion"
}
{for key,value in var.worlds_instance : "${key}" => upper(value)}

Filter:
[for key,value in var.worlds_instance : upper(key) if value == "Lich"]