from sqlalchemy import Column, Integer, DateTime, ForeignKey, Boolean
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.database import Base


class ActivitySignup(Base):
    __tablename__ = "activity_signups"

    id = Column(Integer, primary_key=True, index=True)
    activity_id = Column(Integer, ForeignKey("activities.id"))
    user_id = Column(Integer, ForeignKey("users.id"))
    signup_time = Column(DateTime(timezone=True), server_default=func.now())
    check_in = Column(Boolean, default=False)

    activity = relationship("Activity", back_populates="signups")
    user = relationship("User", back_populates="signups")
