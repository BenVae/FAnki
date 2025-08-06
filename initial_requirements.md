## Anki Ai

This app will use this existing anki flutter app to build an ai infromation processing tool to create anki cards.

The goal is to be able to drop in a pdf, eg for a lecture. Then the pdf is transcribed and split into bits of information for an anki card. In the structure that is unally used in those cards.

The user should be able to add those cards to an existing "Stapel" or create a new one for it with the reccommendation for a name already generated.

## Development notes
- an ai service should be setup for taks like, 
  - transcibe pdf, 
  - generate given format for cards with bits of information, 
  - maybe more later
- the new code should have the same structure as the existing code
- introduce flutter hooks and use them instead of stateful widgets
