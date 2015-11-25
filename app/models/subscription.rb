class Subscription < ActiveHash::Base

  self.data = [
    {id: 1, text: 'annual'},
    {id: 2, text: 'monthly'},
  ]

  alias :to_s :text

  ANNUAL = Subscription.find(1)
  MONTHLY = Subscription.find(2)
end