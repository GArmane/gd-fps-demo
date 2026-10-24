@abstract
@icon("res://addons/at-icons/node/ammunition.svg")
class_name AmmoBehaviour extends Resource

@abstract func can_consume(state: AmmoState) -> bool
@abstract func consume(state: AmmoState) -> AmmoState
@abstract func can_reload(state: AmmoState) -> bool
@abstract func reload(state: AmmoState) -> AmmoState
@abstract func refill(state: AmmoState) -> AmmoState
