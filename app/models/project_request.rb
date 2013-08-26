class ProjectRequest < Request

  field :project_membership_nature_uris, type: Array

  def accept!
    create_project_membership!
  end

  def create_project_membership!
    transaction = Tripod::Persistence::Transaction.new

    self.project_membership_nature_uris.each do |pmnu|

      project_membership = ProjectMembership.new
      project_membership.organisation = self.requestor.uri.to_s
      project_membership.project      = self.requestable.uri.to_s
      project_membership.nature       = pmnu

      if project_membership.save(transaction: transaction)
        transaction.commit

        # TODO Send acceptance notification

        self.responded_to = true
        self.save

        true
      else
        transaction.abort
        false
      end

    end

  end

end