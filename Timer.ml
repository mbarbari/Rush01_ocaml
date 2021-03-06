(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   timer.ml                                           :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: mbarbari <marvin@42.fr>                    +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2015/11/16 11:11:45 by mbarbari          #+#    #+#             *)
(*   Updated: 2015/11/18 23:00:27 by sebgoret         ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type t_coord = int * int

let rec static_redraw button_list =
	List.iter (function a -> a#draw_button) button_list

let rec handle_click (t:Tama.tama) (x, y) lst =
	match lst with
		| h::tail when ((h#hasClicked x y) = true) -> h#action
		| h::tail -> handle_click t (x, y) tail
		| _ -> t

let handle_mouse (t:Tama.tama) (x, y) action =
	if action = true
	then
		let screen = (Sdlvideo.set_video_mode 800 600 [])
		in let eat = new Graphics.button_eat t screen 40 380 40 120
		and thunder = new Graphics.button_thunder t screen 40 430 40 120
		and bath = new Graphics.button_bath t screen 40 480 40 120
		and kill = new Graphics.button_kill t screen 40 530 40 120
			in	let lst = [eat; thunder; bath; kill]
				in	let newtama = handle_click t (x, y) lst
					in	let yolo = new Graphics.creature newtama screen 450 80 120 80 in
							let bg = new Graphics.background newtama screen 0 0 200 200 in
							bg#draw_bg;
							static_redraw lst;
							yolo#draw_bg;
							ignore (Sdlvideo.flip screen);
							newtama
	else
		t

let rec handle_event (t:Tama.tama) th =
	if (t#hasOneZero)
		then
		begin
			print_endline "You lose!";
			Tama.set_data_to_file "save.tama" (new Tama.tama 100 100 100 100);
			exit 0
		end
	else
		match Sdlevent.wait_event () with
			| Sdlevent.MOUSEBUTTONDOWN ({ Sdlevent.mbe_button = Sdlmouse.BUTTON_LEFT } as c) ->
				handle_event (handle_mouse t (c.Sdlevent.mbe_x, c.Sdlevent.mbe_y) true) th
			| Sdlevent.MOUSEBUTTONUP ({ Sdlevent.mbe_button = Sdlmouse.BUTTON_LEFT } as c) ->
				handle_event (handle_mouse t (c.Sdlevent.mbe_x, c.Sdlevent.mbe_y) false) th
			| Sdlevent.KEYDOWN { Sdlevent.keysym = Sdlkey.KEY_ESCAPE } ->
				t
			| Sdlevent.USER 0 ->
				begin
					print_endline "you're dying";
					let newtama = t#set_global (-1) 0 0 0
					and screen = (Sdlvideo.set_video_mode 800 600 [])
					in	let bg = new Graphics.background newtama screen 0 0 200 200 in
						bg#draw_bg;
						let eat = new Graphics.button_eat newtama screen 40 380 40 120
						and thunder = new Graphics.button_thunder newtama screen 40 430 40 120
						and bath = new Graphics.button_bath newtama screen 40 480 40 120
						and kill = new Graphics.button_kill newtama screen 40 530 40 120
						in	static_redraw [eat; thunder; bath; kill];
						let tama = new Graphics.creature newtama screen 450 80 120 80 in
						tama#draw_bg;
						ignore (Sdlvideo.flip screen);
						handle_event newtama th
				end
			| _ -> handle_event t th
