class HappyQuote < ApplicationRecord
  include SetsHappyCompany
  belongs_to :happy_customer
  belongs_to :user
  #has_one :happy_project
  has_many :happy_projects
  has_many :happy_reminders, as: :remindable
  has_many :happy_quote_lines,-> { order(position: :asc) }, inverse_of: :happy_quote
  validates_associated :happy_quote_lines

  accepts_nested_attributes_for :happy_quote_lines, reject_if: :all_blank, allow_destroy: true

  validates :terms,      presence: true
  validates :fob,      presence: true
  validates :quote_date,      presence: true
  validates :estimated_delivery_date,      presence: true
  #validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :shipping_street1,      presence: true
  validates :shipping_city,      presence: true
  validates :shipping_state,      presence: true
  validates :shipping_zipcode,      presence: true


  scope :active, -> { where(active: true) }

   scope :same_family_as_number, ->(number) {
    root = number.to_s.split("-").first
    where("split_part(number, '-', 1) = ?", root)
   }

  def draft_siblings!
    self.class
      .same_family_as_number(number)
      .where.not(id: id)
      .update_all(status: "draft", updated_at: Time.current)
  end


  STATUSES = {
    draft:    "draft",
    sent:     "sent",
    pending:  "pending",
    accepted: "accepted",
    ordered:  "ordered",
    complete: "complete",
    won:      "won",
    lost:     "lost",
    canceled: "canceled",
    archived: "archived"
  }.freeze

  WON_STATUSES = %w[accepted ordered complete won].freeze
  LOST_STATUSES = %w[lost rejected].freeze

  before_validation :ensure_status

  def normalized_status
    status.to_s.downcase
  end

  def won?
    WON_STATUSES.include?(normalized_status)
  end

  def lost?
    LOST_STATUSES.include?(normalized_status)
  end

  def archived?
    normalized_status == "archived"
  end

  def open?
    !(won? || lost? || archived?)
  end

  private

  def ensure_status
    self.status = "draft" if status.blank?
  end


  #validates :name,        presence: true, length: { minimum: 3 }
  #validates :email,       presence: true, format: { with: /.+@.+\.{1}.{2,}/ }
  #validates :password,    length: { within: 8..40 }
  #validates :avatar,      presence: true
  #validates :bio,         length: { within: 100..900 }    
  #validates :birthday,    presence: true, timeliness: { type: :date, :after => lambda { Date.today } }
  #validates :color,       presence: true
  #validates :fruit,       presence: true, exclusion_array: { in: User::FRUIT.first, presence: true, deny_blank: true }
  #validates :music,       presence: true, exclusion_array: { in: User::MUSIC.first, presence: true, deny_blank: true }
  #validates :language,    inclusion: { in: User::LANGUAGE.map(&:to_s) }
  #validates :pill,        inclusion: { in: [User::PILL.first.to_s] }
  #validates :choises,     presence: true, exclusion_array: { in: User::CHOISES.first, presence: true, deny_blank: true }
  #validates :active,      presence: true, acceptance: true
  #validates :friends,     numericality: { only_integer: true, greater_than: 1, less_than: 10_000 }
  #validates :mood,        numericality: { only_integer: true, greater_than: 50, less_than_or_equal_to: 100 } 
  #validates :awake,       presence: true, timeliness: { type: :time, before: '12:00' }
  #validates :first_kiss,  presence: true, timeliness: { type: :datetime, after: '20:00' }
  #validates :terms,       acceptance: true

  
end
