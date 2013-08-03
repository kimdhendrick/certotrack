class InspectionType < ActiveHash::Base

  self.data = [
    {id: 1, text: 'Inspectable'},
    {id: 2, text: 'Non-Inspectable'}
  ]

  alias :to_s :text

  INSPECTABLE = InspectionType.find(1)
  NON_INSPECTABLE = InspectionType.find(2)
end