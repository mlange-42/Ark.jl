# Architecture

This chapter describes the principles of Ark's architecture,
which may be useful to understand what is actually going on,
and to understand performance trade-offs.

## Archetypes

Ark uses an archetype-based architecture (therefore its name).

An archetype represents a unique combination of components.
Each archetype stores the component data for all entities that share exactly that combination.
You can think of an archetype as a table, where rows correspond to entities
and columns represent components. The first column always contains the entity identifiers themselves.

The ASCII graph below illustrates the approach.

```text
 Entities   Archetypes   Bitmasks   Component index
                                    .-----------.
                                    | A | B | C |
   E         E Comps                '-----------'
  |0|       |2|A|B|C|    111... <-----|<--|<--|
  |1|---.   |8|A|B|C|                 |   |   |
  |2|   '-->|1|A|B|C|                 |   |   |
  |3|       |3|A|B|C|                 |   |   |
  |4|                                 |   |   |
  |6|   .-->|7|A|B|      110... <-----'<--|   |
  |7|---'   |6|A|B|                       |   |
  |8|       |4|A|B|                       |   |
  |9|---.                                 |   |
  |.|   |   |5|B|C|      011... <---------'<--'
  |.|   '-->|9|B|C|
  |.|
  |.| <===> [Entity pool]
```
*Illustration of Ark's archetype-based architecture.*


## World component access

## Component index

## Relationships
