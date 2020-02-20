

# Geographic Coverage (div id geo_btn)
id		value

geo_1	straat
geo_2	buurt
geo_3	wijk

geo_4	gebied
geo_5	stadsdeel
geo_6	stad

geo_7	amstelland
geo_8	adam
geo_9	g4
geo_10	national



# Population (div id pop_btn)
id		value

pop_1	young
pop_2	youth
pop_3	adult
pop_4	elderly



# Data Type (div id type_btn)
id		value

type_1	questionnaire
type_2	socialmedia
type_3	promotion
type_4	registry
type_5	monitor



# Level (div id level_btn)
id		value

level_1	individual
level_2	family
level_3	group
level_4	orga
level_5	geographic



# Size (div id size_btn)
id		value

size_1	100
size_2	500
size_3	1000
size_4	2000
size_5	0	



# Department (div id dep_btn)
id		value

dep_1	EGZ
dep_2	IZ
dep_3	JGZ
dep_4	VT
dep_5	MGGZ
dep_6	FGMA
dep_7	GHOR
dep_8	LO
dep_9	AAGG



# Years (div id year_btn)
Values are set automatically, e.g., year starts with the current year. 
The value for the "earlier" button is set to 0.

id 		value
year_1 	2020
year_2	2019
year_3	2018
...
year_17	2004
year_18	0


Values are controlled using class, not ids (because there are several component to update).
Classes are year_1, year_2, year_3, ..., year_17, year_18.

If it is complicated to control the button using classes instead of ids, 
we need to group the svg elements by year, e.g. in index.html ~l.567:

<g id="year_1" >
    <path class="year_1" d="M251.97,68.36l8.21-22.57c-12.84-4.34-26.53-6.82-40.75-7.13v24C230.77,62.97,241.7,64.95,251.97,68.36z"/>
    <text transform="matrix(1 0 0 1 288.203 55.0738)" class="time_font year_1" id='year_1'>2020</text>
</g>

