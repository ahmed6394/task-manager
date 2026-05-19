from pydantic import BaseModel
from datetime import datetime
from typing import Optional


class TodoBase(BaseModel):
    content: str
    status: bool = False


class TodoCreate(TodoBase):
    pass


class TodoUpdate(BaseModel):
    content: Optional[str] = None
    status: Optional[bool] = None


class TodoResponse(TodoBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
