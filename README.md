# ShakeDraCor
This corpus comprises 37 Shakespeare plays. Our source is the fantastic [Folger Shakespeare Library](https://www.folgerdigitaltexts.org/) (released under the [CC BY-NC 3.0](https://creativecommons.org/licenses/by-nc/3.0/deed.en_US) licence).

The texts were prepared to seemlessly integrate with the DraCor pipeline. Network extraction works out of the box. Click on any play at https://dracor.org/shake and see what happens (e.g., *[Macbeth](https://dracor.org/shake/macbeth)*).

We also added Wikidata IDs per play.

# Documentation
The Folger documentation is **[here](http://www.folgerdigitaltexts.org/fdt_documentation.pdf)** (PDF).

Excerpt (regarding the encoding of characters):

<blockquote>"Specifying who participates in a stage direction can be an interesting challenge, especially for ambiguous and permissive stage directions. We have created a new character referencing system to deal with the known and the ambiguous. Clearly identified individuals are identified with their mixed case name followed by the abbreviation of their most significant play. Thus, Hamlet is Hamlet_Ham, Falstaff is Falstaff_1H4 (even in 2H4), and the Duke of Gloucester in 3H6 is RichardIII_R3. Characters who do not have names may be identified in relation to a group of characters, expressed in capital letters. There is an attempt to develop a controlled vocabulary, so Mariners are SAILORS, Keepers are JAILERS, and Captains may be SOLDIERS. ATTENDANTS is a catch-all category that can include Lords, Gentlemen, Torchbearers, Servants, and others. A decimal-based system allows us to add more information as we have it. Brutus's soldier Titinius is SOLDIERS.BRUTUS.Titinius_JC. The First Soldier in that army is SOLDIERS.BRUTUS.1_JC. These still refer to individual characters. With messengers, for example, when we are not sure if the messenger in one scene is the same as the messenger in another, we use .X as a kind of algebraic variable. MESSENGERS.1 cannot be MESSENGERS.2, but MESSENGERS.X might be. When it is impossible to track an individual's entrances and exits, or when it is difficult to know how many characters are in the group, we prefer to track the group rather than individuals. The .0 modifier is used to single out actions by a subset of the group. If a group of ATTENDANTS enters, one is sent on an errand, and then the rest leave, that one is identified as ATTENDANTS.0.1."</blockquote>
