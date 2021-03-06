(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   tama_cthulhu.ml                                    :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: mbarbari <mbarbari@student.42.fr>          +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/11/14 15:16:30 by mbarbari          #+#    #+#             *)
(*   Updated: 2015/11/18 22:42:23 by sebgoret         ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

exception EMPTY_FILE

class tama (hp: int) (energy: int) (hygiene: int) (happiness: int) =
object (self)
	val _name           = "Nyarlathotep"
	val _default        = 100
	val _hp_by_time     = 1
	val _hp             = hp
	val _energy         = energy
	val _hygiene        = hygiene
	val _happiness      = happiness

        (* ****** CONTROLE FUNCTION ***************************************** *)
	method control_value (oldval: int) (addval: int) :int =
		if ((oldval + addval) >= _default)
			then _default
		else
			(oldval + addval)

        (* ****** GETTEUR *************************************************** *)
	method get_name             = _name
	method get_hp               = _hp
	method get_energy           = _energy
	method get_hygiene          = _hygiene
	method get_happiness        = _happiness

        (* ****** SETTEUR *************************************************** *)
	method private set_hp            (a: int) =
		{<_hp = (self#control_value self#get_hp a); _energy = self#get_energy; _hygiene = self#get_hygiene; _happiness = self#get_happiness>}

	method private set_energy        (a: int) =
		{<_hp = self#get_hp; _energy = (self#control_value self#get_energy a); _hygiene = self#get_hygiene; _happiness = self#get_happiness>}

	method private set_hygiene       (a: int) =
		{<_hp = self#get_hp; _energy = self#get_energy; _hygiene = (self#control_value self#get_hygiene a); _happiness = self#get_happiness>}

	method private set_happiness     (a: int) =
		{<_hp = self#get_hp; _energy = self#get_energy; _hygiene = self#get_hygiene; _happiness = (self#control_value self#get_happiness a)>}

	method set_global        (a: int) (b: int) (c: int) (d: int) =
		new tama	(self#control_value self#get_hp a)
					(self#control_value self#get_energy b)
					(self#control_value self#get_hygiene c)
					(self#control_value self#get_happiness d)


    (* ****** SPE METHOD ************************************************ *)
    (*                                        HP    EN    HY    HAP     * *)
	method eat     :tama =  (self#set_global (25) (-10) (-20) (5))
	method thunder :tama =  (self#set_global (-20) (25) (0) (-20))
	method bath    :tama =  (self#set_global (-20) (-10) (25) (5))
	method kill    :tama =  (self#set_global (-20) (-10) (0) (20))

	method hasOneZero :bool = (self#get_hp <= 0 || self#get_energy <= 0 || self#get_hygiene <= 0 || self#get_happiness <= 0)

	method to_string :string = ("tama : " ^ (self#get_name) ^ " " ^
                                    " | HP : " ^ (string_of_int self#get_hp) ^ " " ^
                                    " | Energy : " ^ (string_of_int self#get_energy) ^ " " ^
                                    " | Hygien : " ^ (string_of_int self#get_hygiene) ^ " " ^
                                    " | Happy : " ^ (string_of_int self#get_happiness) )
end


(* ************************************************************************** *)
(* ************************************************************************** *)

let get_data_of_file (file: string) :tama=
	if (Sys.file_exists file) then
		begin
			let ic = open_in file in
					let rec loop_args (arg: int list) =
						try
							loop_args ((int_of_string (input_line ic))::arg)
						with
							|End_of_file -> close_in ic;
								if ((List.length arg) < 4) then
									(print_endline "Empty file or incomplete file!"; [])
								else (List.rev arg)
					in
					let create_objs =
						function
							| a::b::c::d::[] -> (new tama a b c d)
							| _ -> (new tama 100 100 100 100)
					in create_objs (loop_args [])
		end
	else
		(new tama 100 100 100 100)

let set_data_to_file (file: string) (obj: tama) =
	let oc = open_out file in
(*	Printf.fprintf oc "%s\n" (obj#get_name);*)
	Printf.fprintf oc "%s\n" (string_of_int obj#get_hp);
	Printf.fprintf oc "%s\n" (string_of_int obj#get_energy);
	Printf.fprintf oc "%s\n" (string_of_int obj#get_hygiene);
	Printf.fprintf oc "%s\n" (string_of_int obj#get_happiness);
	close_out oc
