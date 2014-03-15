module LinkHelper
  def confirm_delete_link(confirmation_msg)
    @template.link_to 'Delete', model, method: :delete, data: {confirm: confirmation_msg}
  end
end