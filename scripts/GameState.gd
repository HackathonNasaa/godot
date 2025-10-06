extends Node


signal budget_changed(new_budget)

const INITIAL_BUDGET = 5000 # <------- BUDGET DO JOGADOR

var budget: int = INITIAL_BUDGET:
	set(value):
		budget = value
		emit_signal("budget_changed", budget)

func can_afford(price: int) -> bool:
	return budget >= price


func spend(price: int):
	self.budget -= price

func add_to_budget(amount: int):
	self.budget += amount
