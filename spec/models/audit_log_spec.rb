require 'rails_helper'

describe AuditLog do
  it { should belong_to(:user) }
  it { should belong_to(:idea) }
end
