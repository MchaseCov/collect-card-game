AiBoardClear.create(
  [
    {
      card_weight: { damage: 2, target: 'opponent_cards', count: 7 },
      card_constant: CardConstant.find_by(name: 'Flame Nova')
    }
  ]
)
