extends Character
func calculate_total_modifiers():
	for attribute in attributes:
		calculate_value_modifiers(attribute)
		#apply_attribute_base_value_modifier(attribute)
		#apply_attribute(attribute)
	for parameter in parameters:
		calculate_value_modifiers(parameter)
	for energy in energies:
		calculate_energy_value_modifiers(energy)
func calculate_value_modifiers(attribute):
		var total_value_added = 0
		var total_added_value_multiplier = 0
		var total_global_value_multiplier = 1
		for modifier in modifiers:
			if attribute in modifiers[modifier]:
				total_value_added += modifiers[modifier][attribute]["base_added"]
				total_added_value_multiplier += modifiers[modifier][attribute]["added_multiplier"]
				total_global_value_multiplier = total_global_value_multiplier * modifiers[modifier][attribute]["global_multiplier"]
		if attribute in total_modifications:
			total_modifications[attribute][0] += total_value_added
			total_modifications[attribute][1] += total_added_value_multiplier
			total_modifications[attribute][2] = total_modifications[attribute][2]*total_global_value_multiplier
		else:
			total_modifications[attribute] = [total_value_added,(total_added_value_multiplier+1),total_global_value_multiplier]
func calculate_energy_value_modifiers(energy):
		var total_energy_added = 0
		var total_added_energy_multiplier = 0
		var total_global_energy_multiplier = 1
		var total_energy_regen_added = 0
		var total_added_energy_regen_multiplier = 0
		var total_global_energy_regen_multiplier = 1
		for modifier in modifiers:
			if energy in modifiers[modifier]:
				print(energy+" energy found")
				total_energy_added += modifiers[modifier][energy]["base_added"]
				total_added_energy_multiplier += modifiers[modifier][energy]["added_multiplier"]
				total_global_energy_multiplier = total_global_energy_multiplier * modifiers[modifier][energy]["global_multiplier"]
			var regen = energy+"_regen"
			if (regen) in modifiers[modifier]:
				print(energy+" energy regen found")
				total_energy_regen_added += modifiers[modifier][regen]["base_added"]
				total_added_energy_regen_multiplier += modifiers[modifier][regen]["added_multiplier"]
				total_global_energy_regen_multiplier = total_global_energy_regen_multiplier * modifiers[modifier][regen]["global_multiplier"]
		if energy in total_modifications:
			total_modifications[energy][0] += total_energy_added
			total_modifications[energy][1] += total_added_energy_multiplier
			total_modifications[energy][2] = total_modifications[energy][2]*total_global_energy_multiplier
		else:
			total_modifications[energy] = [total_energy_added,(total_added_energy_multiplier+1),total_global_energy_multiplier]
		var regen = energy+"_regen"
		if regen in total_modifications:
			total_modifications[regen][0] += total_energy_regen_added
			total_modifications[regen][1] += total_added_energy_regen_multiplier
			total_modifications[regen][2] = total_modifications[regen][2]*total_global_energy_regen_multiplier
		else:
			total_modifications[regen] = [total_energy_regen_added,(total_added_energy_regen_multiplier+1),total_global_energy_regen_multiplier]
func apply_value_modifiers():
	for attribute in attributes:
		apply_attribute_value_modifier(attribute)
		#apply_attribute(attribute)
	for parameter in parameters:
		apply_parameter_value_modifier(parameter)
	for energy in energies:
		apply_energy_value_modifier(energy)
func apply_attribute_base_value_modifier(attribute):
	if attribute in total_modifications:
		attributes[attribute] = (total_modifications[attribute][0])*(total_modifications[attribute][1])*total_modifications[attribute][2]
func apply_attribute_value_modifier(attribute):
	if attribute in temporary_modifications:
		if attribute in total_modifications:
			attributes[attribute] = (total_modifications[attribute][0]+temporary_modifications[attribute][0])*(total_modifications[attribute][1]+temporary_modifications[attribute][1])*total_modifications[attribute][2]*temporary_modifications[attribute][2]
		else:
			attributes[attribute] = (temporary_modifications[attribute][0])*(temporary_modifications[attribute][1])*temporary_modifications[attribute][2]
	elif attribute in total_modifications:
		attributes[attribute] = (total_modifications[attribute][0])*(total_modifications[attribute][1])*total_modifications[attribute][2]
func apply_parameter_value_modifier(parameter):
	if parameter in temporary_modifications:
		if parameter in total_modifications:
			parameters[parameter] = (total_modifications[parameter][0]+temporary_modifications[parameter][0])*(total_modifications[parameter][1]+temporary_modifications[parameter][1])*total_modifications[parameter][2]*temporary_modifications[parameter][2]
		else:
			parameters[parameter] = (temporary_modifications[parameter][0])*(temporary_modifications[parameter][1])*temporary_modifications[parameter][2]
	elif parameter in total_modifications:
		parameters[parameter] = (total_modifications[parameter][0])*(total_modifications[parameter][1])*total_modifications[parameter][2]
func apply_energy_value_modifier(energy):
	print(temporary_modifications)
	if energy in temporary_modifications:
		if energy in total_modifications:
			print(energy)
			print("base added: ",total_modifications[energy][0]+temporary_modifications[energy][0])
			print("base mult added: ",total_modifications[energy][1]+temporary_modifications[energy][1])
			print("global mult added: ",total_modifications[energy][2]*temporary_modifications[energy][2])
			energies[energy][1] = (total_modifications[energy][0]+temporary_modifications[energy][0])*(total_modifications[energy][1]+temporary_modifications[energy][1])*total_modifications[energy][2]*temporary_modifications[energy][2]
		else:
			energies[energy][1] = (temporary_modifications[energy][0])*(temporary_modifications[energy][1])*temporary_modifications[energy][2]
	elif energy in total_modifications:
		energies[energy][1] = (total_modifications[energy][0])*(total_modifications[energy][1])*total_modifications[energy][2]
	var regen = energy+"_regen"
	if regen in temporary_modifications:
		if regen in total_modifications:
			energies[energy][2] = (total_modifications[regen][0]+temporary_modifications[regen][0])*(total_modifications[regen][1]+temporary_modifications[regen][1])*total_modifications[regen][2]*temporary_modifications[regen][2]
		else:
			energies[energy][2] = (temporary_modifications[regen][0])*(temporary_modifications[regen][1])*temporary_modifications[regen][2]
	elif regen in total_modifications:
		energies[energy][2] = (total_modifications[regen][0])*(total_modifications[regen][1])*total_modifications[regen][2]
func apply_attributes():
	for attribute in attributes:
		apply_attribute(attribute)
func apply_attribute(attribute):
	if attribute in modifiers:
			print(attribute)
			for effect in modifiers[attribute]["effects"]:
				print(effect)
				if effect != "base":
					var base_added = modifiers[attribute]["effects"][effect][0]*attributes[attribute]
					var added_multiplier = modifiers[attribute]["effects"][effect][1]*attributes[attribute]
					var global_multiplier = 1+modifiers[attribute]["effects"][effect][2]*attributes[attribute]
					print(base_added)
					modifiers[attribute][effect]={
						"base_added":base_added,
						"added_multiplier":added_multiplier,
						"global_multiplier":global_multiplier
					}

func calculate_temporary_modifiers():
	temporary_modifications = {}
	for attribute in attributes:
		calculate_temporary_value_modifiers(attribute)
		apply_temporary_attribute(attribute)
	for parameter in parameters:
		calculate_temporary_value_modifiers(parameter)
	for energy in energies:
		calculate_temporary_energy_value_modifiers(energy)
func calculate_temporary_value_modifiers(attribute):
		var total_value_added = 0
		var total_added_value_multiplier = 0
		var total_global_value_multiplier = 1
		for modifier in temporary_modifiers:
			if attribute in temporary_modifiers[modifier]:
				total_value_added += temporary_modifiers[modifier][attribute]["base_added"]
				total_added_value_multiplier += temporary_modifiers[modifier][attribute]["added_multiplier"]
				total_global_value_multiplier = total_global_value_multiplier * temporary_modifiers[modifier][attribute]["global_multiplier"]
		if attribute in temporary_modifications:
			temporary_modifications[attribute][0] += total_value_added
			temporary_modifications[attribute][1] += total_added_value_multiplier
			temporary_modifications[attribute][2] = temporary_modifications[attribute][2]*total_global_value_multiplier
		else:
			temporary_modifications[attribute] = [total_value_added,(total_added_value_multiplier),total_global_value_multiplier]
func apply_temporary_attribute(attribute):
	if attribute in modifiers:
			print(attribute)
			for effect in modifiers[attribute]["effects"]:
				print(effect)
				if effect != "base":
					var total_attribute = (temporary_modifications[attribute][0]+total_modifications[attribute][0])*(temporary_modifications[attribute][1]+total_modifications[attribute][1])*temporary_modifications[attribute][2]*total_modifications[attribute][2]
					var base_added = modifiers[attribute]["effects"][effect][0]*total_attribute
					var added_multiplier = modifiers[attribute]["effects"][effect][1]*total_attribute
					var global_multiplier = 1+modifiers[attribute]["effects"][effect][2]*total_attribute
					print(total_attribute)
					if attribute in temporary_modifiers:
						if effect not in temporary_modifiers[attribute]:
							temporary_modifiers[attribute][effect]={}
							temporary_modifiers[attribute][effect]["base_added"]=0
							temporary_modifiers[attribute][effect]["added_multiplier"]=0
							temporary_modifiers[attribute][effect]["global_multiplier"]=1
						temporary_modifiers[attribute][effect]["base_added"]+=base_added
						temporary_modifiers[attribute][effect]["added_multiplier"]+=added_multiplier
						temporary_modifiers[attribute][effect]["global_multiplier"]=temporary_modifiers[attribute][effect]["global_multiplier"]*global_multiplier
					else:
						temporary_modifiers[attribute] = {}
						temporary_modifiers[attribute][effect]={
							"base_added":base_added,
							"added_multiplier":added_multiplier,
							"global_multiplier":global_multiplier
						}
func calculate_temporary_energy_value_modifiers(energy):
		var total_energy_added = 0
		var total_added_energy_multiplier = 0
		var total_global_energy_multiplier = 1
		var total_energy_regen_added = 0
		var total_added_energy_regen_multiplier = 0
		var total_global_energy_regen_multiplier = 1
		for modifier in temporary_modifiers:
			if energy in temporary_modifiers[modifier]:
				print(energy+" energy found")
				total_energy_added += temporary_modifiers[modifier][energy]["base_added"]
				total_added_energy_multiplier += temporary_modifiers[modifier][energy]["added_multiplier"]
				total_global_energy_multiplier = total_global_energy_multiplier * temporary_modifiers[modifier][energy]["global_multiplier"]
			var regen = energy+"_regen"
			if (regen) in temporary_modifiers[modifier]:
				print(energy+" energy regen found")
				total_energy_regen_added += temporary_modifiers[modifier][regen]["base_added"]
				total_added_energy_regen_multiplier += temporary_modifiers[modifier][regen]["added_multiplier"]
				total_global_energy_regen_multiplier = total_global_energy_regen_multiplier * temporary_modifiers[modifier][regen]["global_multiplier"]
		if energy in temporary_modifications:
			temporary_modifications[energy][0] += total_energy_added
			temporary_modifications[energy][1] += total_added_energy_multiplier
			temporary_modifications[energy][2] = temporary_modifications[energy][2]*total_global_energy_multiplier
		else:
			temporary_modifications[energy] = [total_energy_added,(total_added_energy_multiplier),total_global_energy_multiplier]
		var regen = energy+"_regen"
		if regen in temporary_modifications:
			temporary_modifications[regen][0] += total_energy_regen_added
			temporary_modifications[regen][1] += total_added_energy_regen_multiplier
			temporary_modifications[regen][2] = temporary_modifications[regen][2]*total_global_energy_regen_multiplier
		else:
			temporary_modifications[regen] = [total_energy_regen_added,(total_added_energy_regen_multiplier),total_global_energy_regen_multiplier]
