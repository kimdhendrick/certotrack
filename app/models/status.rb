class Status < ActiveHash::Base
  include Comparable

  self.data = [
    {id: 1, text: 'Valid'},
    {id: 2, text: 'Warning'},
    {id: 3, text: 'Expired'},
    {id: 4, text: 'Recertify'},
    {id: 5, text: 'Pending'},
    {id: 6, text: 'N/A'},
    {id: 7, text: 'Not Certified'}
  ]

  alias_method :to_s, :text
  alias_method :sort_order, :id

  VALID = Status.find(1)
  EXPIRING = Status.find(2)
  EXPIRED = Status.find(3)
  RECERTIFY = Status.find(4)
  PENDING = Status.find(5)
  NA = Status.find(6)
  NOT_CERTIFIED = Status.find(7)

  def <=>(other)
    sort_order <=> other.sort_order
  end
end