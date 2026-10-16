@abstract
@icon("res://addons/at-icons/node/ammunition.svg")
class_name AmmoBehaviour extends Resource

@abstract func consume(qtd: int = 1) -> int
@abstract func reload() -> bool

@abstract func has_reserve() -> bool
@abstract func is_empty() -> bool
@abstract func is_full() -> bool
