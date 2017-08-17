class Terminal < ApplicationRecord
  has_many :devices, dependent: :destroy, after_add: :set_current_device
  validates :name, presence: true,
                    length: { maximum: 255 }

  default_scope { order(created_at: :desc, name: :asc) }

  before_create :create_pairing_token

  def pairing_token_png(size = 120)
    url = "https://spectre.com/#{self.pairing_token}"
    qr_code = RQRCode::QRCode.new(url, size: 4, level: :m)
    qr_code.as_png(
          resize_gte_to: false,
          resize_exactly_to: false,
          fill: 'white',
          color: 'black',
          size: size,
          border_modules: 0,
          module_px_size: 0,
          file: nil # path to write
          )
  end

  def set_current_device(device)
    self.devices.where.not(imei: device.imei)
                .where(current: true)
                .update_all(current: false)
    self.paired = true
    self.pairing_token = nil
    self.save
  end

  def create_pairing_token
    self.pairing_token = SecureRandom.hex(10)
  end

end
