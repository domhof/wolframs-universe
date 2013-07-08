////////////////////////////////////////////////////////////////
//                                                            //
//  Wolfram's Universe "on 15th of March 2013"                //
//  by Dominik Hofer                                          //
//                                                            //
//  How it works: The date 15th of March is transformed into  //
//  its binary representation and is used as the input to     //
//  Wolfram's Universe, a generative algorithm based on       //
//  simple rules invented by Stephen Wolfram. The evolving    //
//  generations are then used to form a seqeunce of parallel  //
//  sine-based sounds, resulting in an interesting ambient    //
//  composition.                                              //
//                                                            //
////////////////////////////////////////////////////////////////

~universeSize = 64;
~time = 20130315 // 15.03.2013

// Wolframs Universe

~nextEvolution = {|universe|
	var nextUniverse = Array.fill(universe.size,0);

	universe.do({|element, index|
		var left1, left2, right1, right2;
		var lastElem = universe.size - 1;
		var livingNeighbors = 0;

		/*
		"index = ".post;
		index.postln;
		*/

		left1 = index - 1;
		left2 = index - 2;
		if (left1 < 0, {left1 = universe.size + left1});
		if (left2 < 0, {left2 = universe.size + left2});

		right1 = index + 1;
		right2 = index + 2;
		if (right1 >= universe.size, {right1 = right1 - universe.size});
		if (right2 >= universe.size, {right2 = right2 - universe.size});

		/*
		left2.postln;
		left1.postln;
		right1.postln;
		right2.postln;
		*/

		livingNeighbors = universe[left1] + universe[left2] + universe[right1] + universe[right2];

		/*
		"livingNeighbors = ".post;
		livingNeighbors.postln;
		*/

		if (livingNeighbors == 4, {nextUniverse[index] = 1});
		if (livingNeighbors == 2, {nextUniverse[index] = 1});
		}
	);

	nextUniverse;
}

~bigBang = {|universe|
	universe.do({|element, index|
		universe[index] = 2.rand;
	});
}

// Represents time as binary string and uses it to initialize the universe.
~toUniverse = {|decimal|
	var universe = Array.fill(~universeSize / 2, 0);
	var i = 0;
	(universe.size - 1).do {
		i = i + 1;
		decimal = decimal >> 1;
		if ( 1 == (decimal & 1) , { universe[i] = 1 }, { universe[i] = 0 });
	};

	// trim
	i = ~universeSize - 1;
	{i < ~universeSize && universe[i] != 1}.while ({ i = i - 1; });
	universe = universe[0..i];

	universe;
}


(
var universe = ~toUniverse.(~time);

//"Big Bang: ".post;
//universe = ~bigBang.(universe);

universe.postln;

t = Task.new {
    inf.do({
		universe.do({|element, index|

			if (element == 1, {

				fork{
					var h = (2**5) * (index + 1) + 50;
					//h.postln;
					play{
						Splay.ar({
							SinOsc.ar(exprand(h,h+(h/64)),0,0.1)
						}!64, 1, 1, ((universe.size / 2) - index) * (-0.01))*LFGauss.ar(9,1/4,0,0,2);
					};
				};

			});
		});

		universe = ~nextEvolution.(universe);
		universe.postln;

        3.wait;
    });
};
)
t.start // Start

s.meter